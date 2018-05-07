#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

#ifdef CS333_P3P4 // P3
struct StateLists {
  struct proc * ready;
  struct proc * readyTail;
  struct proc * free;
  struct proc * freeTail;
  struct proc * sleep;
  struct proc * sleepTail;
  struct proc * zombie;
  struct proc * zombieTail;
  struct proc * running;
  struct proc * runningTail;
  struct proc * embryo;
  struct proc * embryoTail;
};
#endif

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
  #ifdef CS333_P3P4
  struct StateLists pLists; // P3
  #endif
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);


#ifdef CS333_P3P4
static void initProcessLists(void);
static void initFreeList(void);
static int stateListAdd(struct proc** head, struct proc** tail, struct proc* p);
static int stateListRemove(struct proc** head, struct proc** tail, struct proc* p);
static void statelist_move_from_to(enum procstate, enum procstate, struct proc*);
static void get_head_tail(struct proc***, struct proc***, enum procstate);
static struct proc* get_head(enum procstate state);
static void assertState(struct proc* p, enum procstate state);
static struct proc* statelist_search(int pid);
static struct proc* list_search(int pid, enum procstate state);
static void statelist_abandon_children(struct proc* p);
static void list_abandon_children(struct proc* parent, enum procstate state);
static void list_display(struct proc*);
#endif

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
//cprintf("entering allocproc()\n");
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  #ifdef CS333_P3P4
  p = ptable.pLists.free;
  if (p)
    goto found;
  #else
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    if(p->state == UNUSED)
      goto found;
  }
  #endif
  release(&ptable.lock);
  return 0;

found:
  #ifdef CS333_P3P4
  statelist_move_from_to(UNUSED, EMBRYO, p);
  #else
  p->state = EMBRYO;
  #endif
  p->pid = nextpid++;
  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    #ifdef CS333_P3P4
    statelist_move_from_to(EMBRYO, UNUSED, p);
    #else
    p->state = UNUSED;
    #endif
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
//cprintf("entering forkret() from allocproc()\n");
  p->context->eip = (uint)forkret;
//cprintf("returned to allocproc() from forkret()\n");

//student added
  #ifdef CS333_P1
  p->start_ticks = ticks;
  #endif
  #ifdef CS333_P2
  p->cpu_ticks_total = 0;
  p->cpu_ticks_in = 0;
  #endif

//cprintf("leaving allocproc()\n");
  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

//cprintf("entering userinit()\n");
  #ifdef CS333_P3P4
  acquire(&ptable.lock);
  initProcessLists();
  initFreeList();
  release(&ptable.lock);
  #endif

  p = allocproc();
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  #ifdef CS333_P2
  p->parent = 0;
  p->uid = DEFAULT_UID;
  p->gid = DEFAULT_GID;
  #endif

  #ifdef CS333_P3P4
  acquire(&ptable.lock);
  statelist_move_from_to(EMBRYO, RUNNABLE, p);
  release(&ptable.lock);
  #else
  p->state = RUNNABLE;
  #endif
//cprintf("leaving userinit()\n");
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;

  sz = proc->sz;
  if(n > 0){
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  proc->sz = sz;
  switchuvm(proc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
//cprintf("entering fork\n");

  // Allocate process.
  if((np = allocproc()) == 0)
    return -1;

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    #ifdef CS333_P3P4
    statelist_move_from_to(EMBRYO, UNUSED, np);
    #else
    np->state = UNUSED;
    #endif
    return -1;
  }
  np->sz = proc->sz;
  np->parent = proc;
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);

  safestrcpy(np->name, proc->name, sizeof(proc->name));

  pid = np->pid;
  #ifdef CS333_P2
  np->uid = proc->uid;
  np->gid = proc->gid;
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
  #ifdef CS333_P3P4
  statelist_move_from_to(EMBRYO, RUNNABLE, np);
  #else
  np->state = RUNNABLE;
  #endif
  release(&ptable.lock);

//cprintf("leaving fork\n");
  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
  struct proc *p;
  int fd;

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == proc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}
#else
void
exit(void)
{
  //struct proc *p;
  int fd;
//cprintf("entering exit()\n");

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(proc->ofile[fd]){
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(proc->cwd);
  end_op();
  proc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  statelist_abandon_children(proc);
  // Jump into the scheduler, never to return.
  statelist_move_from_to(RUNNING, ZOMBIE, proc);

//cprintf("calling sched() from exit()\n");

  sched();
  panic("zombie exit");
}
#endif

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->state = UNUSED;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
}
#else
int
wait(void)
{
//cprintf("entering wait()\n");
  struct proc *p;
  int havekids, pid, state;

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for (state = 1; state <= ZOMBIE; ++state) {
      p = get_head(state);
      while (p) {
        if(p->parent != proc) {
          p = p->next;
          continue;
        }
        havekids = 1;
        if(p->state == ZOMBIE){
          // Found one.
          pid = p->pid;
          kfree(p->kstack);
          p->kstack = 0;
          freevm(p->pgdir);
          statelist_move_from_to(ZOMBIE, UNUSED, p);
          p->pid = 0;
          p->parent = 0;
          p->name[0] = 0;
          p->killed = 0;
          release(&ptable.lock);
          return pid;
        }
        p = p->next;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
  }
//cprintf("leaving wait()\n");
}
#endif

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      #ifdef CS333_P2
      p->cpu_ticks_in = ticks;
      #endif
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}

#else // if CS333_P3P4
void
scheduler(void)
{
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();

    idle = 1;  // assume idle unless we schedule a process
    acquire(&ptable.lock);
    p = ptable.pLists.ready;
    if(p) {
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
      proc = p;
      switchuvm(p);
      statelist_move_from_to(RUNNABLE, RUNNING, p);
      //p->state = RUNNING;
      #ifdef CS333_P2
      p->cpu_ticks_in = ticks;
      #endif
      swtch(&cpu->scheduler, proc->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
    // if idle, wait for next interrupt
    if (idle) {
      sti();
      hlt();
    }
  }
}
#endif

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
  int intena;

//cprintf("entering sched()\n");
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(cpu->ncli != 1)
    panic("sched locks");
  if(proc->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = cpu->intena;
  #ifdef CS333_P2
  proc->cpu_ticks_total += ticks - proc->cpu_ticks_in;
  #endif
  swtch(&proc->context, cpu->scheduler);
  cpu->intena = intena;
//cprintf("leaving sched()\n");
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
//cprintf("entering yield()\n");
  acquire(&ptable.lock);  //DOC: yieldlock
  #ifdef CS333_P3P4
    statelist_move_from_to(RUNNING, RUNNABLE, proc);
  #else
    proc->state = RUNNABLE;
  #endif
  sched();
  release(&ptable.lock);
//cprintf("leaving yield()\n");
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }
  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
//cprintf("entering sleep()\n");
  if(proc == 0)
    panic("sleep\n");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
    acquire(&ptable.lock);
    if (lk) release(lk);
  }

  // Go to sleep.
  proc->chan = chan;
  #ifdef CS333_P3P4
    statelist_move_from_to(RUNNING, SLEEPING, proc);
  #else
    proc->state = SLEEPING;
  #endif
  sched();

  // Tidy up.
  proc->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){
    release(&ptable.lock);
    if (lk) acquire(lk);
  }
//cprintf("leaving sleep()\n");
}

//PAGEBREAK!
#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{

//cprintf("entering wakeup1()\n");
 struct proc * p = ptable.pLists.sleep;
 struct proc * tmp;
 if (!holding(&ptable.lock))
   panic("not holding ptable.lock in wakeup1() (proc.c)\n");

 while (p) {
   tmp = p;
   p = p->next;
   if (tmp->chan == chan)
     statelist_move_from_to(SLEEPING, RUNNABLE, tmp);
  }
//cprintf("leaving wakeup1()\n");
}
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
//cprintf("entering wakeup()\n");
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
//cprintf("leaving wakeup()\n");
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
#else
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);

  p = statelist_search(pid);

  if(p){
    p->killed = 1;
    // Wake process from sleep if necessary.
    if(p->state == SLEEPING)
      statelist_move_from_to(SLEEPING, RUNNABLE, p);
    release(&ptable.lock);
    return 0;
  }

  release(&ptable.lock);

  return -1;
}
#endif

static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
};

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
#ifdef CS333_P1
void
print_millisec(uint millisec)
{
  cprintf("%d.", millisec /1000);

  millisec %= 1000;
  if (millisec < 100)
    cprintf("0");
  if (millisec < 10)
    cprintf("0");

  cprintf("%d\t", millisec);
}
#endif

#ifdef CS333_P2
int
getprocs(uint max, struct uproc* table)
{
  int num_uprocs, lock = 0;
  struct proc* begin, * end;
  if (!table || max < 1)
    return -1;

  if (!holding(&ptable.lock)) {
    acquire(&ptable.lock);
    lock = 1;
  }

  begin = ptable.proc;
  end = ptable.proc + NPROC;
  num_uprocs = 0;

  while (begin < end && num_uprocs < max) {
    if (begin->state == EMBRYO || begin->state == UNUSED) {
      ++begin;
      continue;
    }
    table->pid = begin->pid;
    table->uid = begin->uid;
    table->gid = begin->gid;
    table->ppid = (begin->parent) ? begin->parent->pid : begin->pid;
    table->elapsed_ticks = ticks - begin->start_ticks;
    table->CPU_total_ticks = begin->cpu_ticks_total;
    if(begin->state >= 0 && begin->state < NELEM(states) && states[begin->state])
      safestrcpy(table->state, states[begin->state], sizeof(table->name));
    else
      safestrcpy(table->state, "???", sizeof(table->name));
    table->size = begin->sz;
    safestrcpy(table->name, begin->name, sizeof(table->name));
    ++begin; ++table; ++num_uprocs;
  }

  if (lock)
    release(&ptable.lock);

  return num_uprocs;
}
#endif

void
procdump(void)
{
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  #ifdef CS333_P2
  uint ppid;

    #ifdef CS333_P3P4
    cprintf("NPROC = %d\n", NPROC);
    #endif
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
  #elif defined(CS333_P1)
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
  #endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";

    #ifndef CS333_P1 
    cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
    #endif
    #ifdef CS333_P1
        #ifdef CS333_P2
          ppid = p->parent ? p->parent->pid : p->pid;
          cprintf("%d\t%s\t%d\t%d\t%d\t", 
              p->pid, p->name, p->uid, p->gid, ppid);
        #else
          cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
        #endif
    // display elapsed time
      print_millisec(ticks - p->start_ticks);
        #ifdef CS333_P2
          print_millisec(p->cpu_ticks_total);
          cprintf("%s\t%d\t",state,p->sz);
        #endif // CS333_P2
    #endif // CS333_p1

    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
  if (*head == 0) {
    *head = p;
    *tail = p;
    p->next = 0;
  } else {
    (*tail)->next = p;
    *tail = (*tail)->next;
    (*tail)->next = 0;
  }

  return 0;
}

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
  if (*head == 0 || *tail == 0 || p == 0) {
    return -1;
  }

  struct proc* current = *head;
  struct proc* previous = 0;

  if (current == p) {
    *head = (*head)->next;
    return 0;
  }

  while(current) {
    if (current == p) {
      break;
    }

    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if (current == 0) {
    return -1;
  }

  // Process found. Set the appropriate next pointer.
  if (current == *tail) {
    *tail = previous;
    (*tail)->next = 0;
  } else {
    previous->next = current->next;
  }

  // Make sure p->next doesn't point into the list.
  p->next = 0;

  return 0;
}

static void
initProcessLists(void) {
  ptable.pLists.ready = 0;
  ptable.pLists.readyTail = 0;
  ptable.pLists.free = 0;
  ptable.pLists.freeTail = 0;
  ptable.pLists.sleep = 0;
  ptable.pLists.sleepTail = 0;
  ptable.pLists.zombie = 0;
  ptable.pLists.zombieTail = 0;
  ptable.pLists.running = 0;
  ptable.pLists.runningTail = 0;
  ptable.pLists.embryo = 0;
  ptable.pLists.embryoTail = 0;
}

static void
initFreeList(void) {
  if (!holding(&ptable.lock)) {
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}

// Student added helpers:
static void
statelist_move_from_to(enum procstate state_from, enum procstate state_to, struct proc* p) {
  if (!p) return;
  int lock = holding(&ptable.lock);
  if (!lock) {
    acquire(&ptable.lock);
  }
//cprintf("moving %s from %s to %s...", p->name, states[state_from], states[state_to]);
  assertState(p, state_from);

  struct proc **head, **tail;
  get_head_tail(&head, &tail, state_from);

  if (stateListRemove(head,tail,p)) {
    panic("in proc.c: in statelist_move_from_to(): proc not found in list for removal\n");
  }

  get_head_tail(&head, &tail, state_to);

  stateListAdd(head, tail, p);
  p->state = state_to;

  if (!lock) release(&ptable.lock);
//cprintf(" done.\n");
}

static void
get_head_tail(struct proc*** head, struct proc*** tail, enum procstate state_from) {
  switch (state_from) {
    case UNUSED:
      *head = &ptable.pLists.free;
      *tail = &ptable.pLists.freeTail;
      break;
    case EMBRYO:
      *head = &ptable.pLists.embryo;
      *tail = &ptable.pLists.embryoTail;
      break;
    case SLEEPING:
      *head = &ptable.pLists.sleep;
      *tail = &ptable.pLists.sleepTail;
      break;
    case RUNNABLE:
      *head = &ptable.pLists.ready;
      *tail = &ptable.pLists.readyTail;
      break;
    case RUNNING:
      *head = &ptable.pLists.running;
      *tail = &ptable.pLists.runningTail;
      break;
    case ZOMBIE:
      *head = &ptable.pLists.zombie;
      *tail = &ptable.pLists.zombieTail;
      break;
    default:
      panic("in get_head_tail(): argument is not a valid state\n");
  }
}

static struct proc*
statelist_search(int pid) {
  struct proc * p;
  for (int i = 0; i <= ZOMBIE; ++i) {
    p = list_search(pid, i);
    if (p) return p;
  }
  return 0;
}

static struct proc*
list_search(int pid, enum procstate state) {
  struct proc **head, **tail, *p;

  get_head_tail(&head, &tail, state);
  p = *head;
  while (p) {
    if (p->pid == pid) return p;
    p = p->next;
  }

  return 0;
}

static struct proc*
get_head(enum procstate state) {
  switch (state) {
    case UNUSED:
      return ptable.pLists.free;
    case EMBRYO:
      return ptable.pLists.embryo;
    case SLEEPING:
      return ptable.pLists.sleep;
    case RUNNABLE:
      return ptable.pLists.ready;
    case RUNNING:
      return ptable.pLists.running;
    case ZOMBIE:
      return ptable.pLists.zombie;
    default:
      panic("in get_head_tail(): argument is not a valid state\n");
  }
}
  

static void
assertState(struct proc* p, enum procstate state) {
  if (!p) 
    panic("in proc.c: in assertState(): proc* is NULL\n");
  if (p->state != state) {
    cprintf("proc state: %s, asserted state: %s\n", states[p->state], states[state]);
    panic("in proc.c: in assertState(): proc state does not match asserted state\n");
  }
}

static void
statelist_abandon_children(struct proc* p) {
  for (int i = 0; i <= ZOMBIE; ++i)
    list_abandon_children(p, i);
}

static void
list_abandon_children(struct proc* parent, enum procstate state) {
  //struct proc **head, **tail;
  struct proc *p;

  //get_head_tail(&head, &tail, state);
  //p = *head;
  p = get_head(state);
  while (p) {
    if (p->parent == parent) {
      p->parent = initproc;
      if (p->state == ZOMBIE)
        wakeup1(initproc);
    }
    p = p->next;
  }
}

static void
list_display(struct proc* p) {
  if (!p) {
    cprintf("Nothing to display\n");
    return;
  }
  int lock = holding(&ptable.lock);
  if (!lock) acquire(&ptable.lock);

  cprintf("%d", p->pid);
  p = p->next;
  while (p) {
  cprintf("->%d", p->pid);
  p = p->next;
  }
  cprintf("\n");

  if (!lock) release(&ptable.lock);
}
  
void
display_readylist() {
  acquire(&ptable.lock);
  cprintf("\nReady List Processes:\n");
  list_display(ptable.pLists.ready);
  release(&ptable.lock);
}

void
display_freelist() {
  int i;
  struct proc* p = ptable.pLists.free;

  for(i = 0; p;++i)
    p = p->next;

  cprintf("\nFree List Size: %d processes\n", i);
}

void
display_sleeplist() {
  cprintf("\nSleep List Processes:\n");
  list_display(ptable.pLists.sleep);
}

void
display_zombielist() {
  struct proc* p = ptable.pLists.zombie;
  cprintf("\nZombie List Processes:\n");

  if (!p) {
    cprintf("Nothing to display\n");
    return;
  }

  cprintf("(%d,%d)", p->pid, (p->parent)? p->parent->pid : p->pid);
  p = p->next;
  while (p) {
    cprintf("->(%d,%d)", p->pid, (p->parent)? p->parent->pid : p->pid);
    p = p->next;
  }
  cprintf("\n");
}

#endif // CS333_P3P4
