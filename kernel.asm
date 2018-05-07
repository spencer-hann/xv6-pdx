
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 41 39 10 80       	mov    $0x80103941,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 38 93 10 80       	push   $0x80109338
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 46 5c 00 00       	call   80105c92 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 ee 5b 00 00       	call   80105cb4 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 0a 5c 00 00       	call   80105d1b <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 dd 4d 00 00       	call   80104f09 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 8e 5b 00 00       	call   80105d1b <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 3f 93 10 80       	push   $0x8010933f
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 d8 27 00 00       	call   801029bf <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 50 93 10 80       	push   $0x80109350
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 97 27 00 00       	call   801029bf <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 57 93 10 80       	push   $0x80109357
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 5a 5a 00 00       	call   80105cb4 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 60 4d 00 00       	call   8010501e <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 4d 5a 00 00       	call   80105d1b <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 df 03 00 00       	call   80100792 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 cd 58 00 00       	call   80105cb4 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 5e 93 10 80       	push   $0x8010935e
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 71 03 00 00       	call   80100792 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 67 93 10 80 	movl   $0x80109367,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 aa 02 00 00       	call   80100792 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 8d 02 00 00       	call   80100792 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 7e 02 00 00       	call   80100792 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 70 02 00 00       	call   80100792 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 bb 57 00 00       	call   80105d1b <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 6e 93 10 80       	push   $0x8010936e
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 7d 93 10 80       	push   $0x8010937d
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 a6 57 00 00       	call   80105d6d <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 7f 93 10 80       	push   $0x8010937f
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006b8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006bc:	78 09                	js     801006c7 <cgaputc+0xc6>
801006be:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006c5:	7e 0d                	jle    801006d4 <cgaputc+0xd3>
    panic("pos under/overflow");
801006c7:	83 ec 0c             	sub    $0xc,%esp
801006ca:	68 83 93 10 80       	push   $0x80109383
801006cf:	e8 92 fe ff ff       	call   80100566 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006d4:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006db:	7e 4c                	jle    80100729 <cgaputc+0x128>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006dd:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006e2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006e8:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006ed:	83 ec 04             	sub    $0x4,%esp
801006f0:	68 60 0e 00 00       	push   $0xe60
801006f5:	52                   	push   %edx
801006f6:	50                   	push   %eax
801006f7:	e8 da 58 00 00       	call   80105fd6 <memmove>
801006fc:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006ff:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100703:	b8 80 07 00 00       	mov    $0x780,%eax
80100708:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010070b:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010070e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100713:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100716:	01 c9                	add    %ecx,%ecx
80100718:	01 c8                	add    %ecx,%eax
8010071a:	83 ec 04             	sub    $0x4,%esp
8010071d:	52                   	push   %edx
8010071e:	6a 00                	push   $0x0
80100720:	50                   	push   %eax
80100721:	e8 f1 57 00 00       	call   80105f17 <memset>
80100726:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100729:	83 ec 08             	sub    $0x8,%esp
8010072c:	6a 0e                	push   $0xe
8010072e:	68 d4 03 00 00       	push   $0x3d4
80100733:	e8 b9 fb ff ff       	call   801002f1 <outb>
80100738:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010073e:	c1 f8 08             	sar    $0x8,%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	83 ec 08             	sub    $0x8,%esp
80100747:	50                   	push   %eax
80100748:	68 d5 03 00 00       	push   $0x3d5
8010074d:	e8 9f fb ff ff       	call   801002f1 <outb>
80100752:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100755:	83 ec 08             	sub    $0x8,%esp
80100758:	6a 0f                	push   $0xf
8010075a:	68 d4 03 00 00       	push   $0x3d4
8010075f:	e8 8d fb ff ff       	call   801002f1 <outb>
80100764:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010076a:	0f b6 c0             	movzbl %al,%eax
8010076d:	83 ec 08             	sub    $0x8,%esp
80100770:	50                   	push   %eax
80100771:	68 d5 03 00 00       	push   $0x3d5
80100776:	e8 76 fb ff ff       	call   801002f1 <outb>
8010077b:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010077e:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100783:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100786:	01 d2                	add    %edx,%edx
80100788:	01 d0                	add    %edx,%eax
8010078a:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
8010078f:	90                   	nop
80100790:	c9                   	leave  
80100791:	c3                   	ret    

80100792 <consputc>:

void
consputc(int c)
{
80100792:	55                   	push   %ebp
80100793:	89 e5                	mov    %esp,%ebp
80100795:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100798:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
8010079d:	85 c0                	test   %eax,%eax
8010079f:	74 07                	je     801007a8 <consputc+0x16>
    cli();
801007a1:	e8 6a fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
801007a6:	eb fe                	jmp    801007a6 <consputc+0x14>
  }

  if(c == BACKSPACE){
801007a8:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007af:	75 29                	jne    801007da <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007b1:	83 ec 0c             	sub    $0xc,%esp
801007b4:	6a 08                	push   $0x8
801007b6:	e8 05 72 00 00       	call   801079c0 <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 f8 71 00 00       	call   801079c0 <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 eb 71 00 00       	call   801079c0 <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 db 71 00 00       	call   801079c0 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	ff 75 08             	pushl  0x8(%ebp)
801007ee:	e8 0e fe ff ff       	call   80100601 <cgaputc>
801007f3:	83 c4 10             	add    $0x10,%esp
}
801007f6:	90                   	nop
801007f7:	c9                   	leave  
801007f8:	c3                   	ret    

801007f9 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007f9:	55                   	push   %ebp
801007fa:	89 e5                	mov    %esp,%ebp
801007fc:	83 ec 28             	sub    $0x28,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  #ifdef CS333_P3P4
  int rl = 0, fl = 0, sl = 0, zl = 0;
80100806:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010080d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100814:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
8010081b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  #endif

  acquire(&cons.lock);
80100822:	83 ec 0c             	sub    $0xc,%esp
80100825:	68 e0 c5 10 80       	push   $0x8010c5e0
8010082a:	e8 85 54 00 00       	call   80105cb4 <acquire>
8010082f:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100832:	e9 a6 01 00 00       	jmp    801009dd <consoleintr+0x1e4>
    switch(c){
80100837:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010083a:	83 f8 12             	cmp    $0x12,%eax
8010083d:	0f 84 d8 00 00 00    	je     8010091b <consoleintr+0x122>
80100843:	83 f8 12             	cmp    $0x12,%eax
80100846:	7f 1c                	jg     80100864 <consoleintr+0x6b>
80100848:	83 f8 08             	cmp    $0x8,%eax
8010084b:	0f 84 95 00 00 00    	je     801008e6 <consoleintr+0xed>
80100851:	83 f8 10             	cmp    $0x10,%eax
80100854:	74 39                	je     8010088f <consoleintr+0x96>
80100856:	83 f8 06             	cmp    $0x6,%eax
80100859:	0f 84 c8 00 00 00    	je     80100927 <consoleintr+0x12e>
8010085f:	e9 e7 00 00 00       	jmp    8010094b <consoleintr+0x152>
80100864:	83 f8 15             	cmp    $0x15,%eax
80100867:	74 4f                	je     801008b8 <consoleintr+0xbf>
80100869:	83 f8 15             	cmp    $0x15,%eax
8010086c:	7f 0e                	jg     8010087c <consoleintr+0x83>
8010086e:	83 f8 13             	cmp    $0x13,%eax
80100871:	0f 84 bc 00 00 00    	je     80100933 <consoleintr+0x13a>
80100877:	e9 cf 00 00 00       	jmp    8010094b <consoleintr+0x152>
8010087c:	83 f8 1a             	cmp    $0x1a,%eax
8010087f:	0f 84 ba 00 00 00    	je     8010093f <consoleintr+0x146>
80100885:	83 f8 7f             	cmp    $0x7f,%eax
80100888:	74 5c                	je     801008e6 <consoleintr+0xed>
8010088a:	e9 bc 00 00 00       	jmp    8010094b <consoleintr+0x152>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010088f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100896:	e9 42 01 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010089b:	a1 28 18 11 80       	mov    0x80111828,%eax
801008a0:	83 e8 01             	sub    $0x1,%eax
801008a3:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
801008a8:	83 ec 0c             	sub    $0xc,%esp
801008ab:	68 00 01 00 00       	push   $0x100
801008b0:	e8 dd fe ff ff       	call   80100792 <consputc>
801008b5:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008b8:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008be:	a1 24 18 11 80       	mov    0x80111824,%eax
801008c3:	39 c2                	cmp    %eax,%edx
801008c5:	0f 84 12 01 00 00    	je     801009dd <consoleintr+0x1e4>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008cb:	a1 28 18 11 80       	mov    0x80111828,%eax
801008d0:	83 e8 01             	sub    $0x1,%eax
801008d3:	83 e0 7f             	and    $0x7f,%eax
801008d6:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
801008dd:	3c 0a                	cmp    $0xa,%al
801008df:	75 ba                	jne    8010089b <consoleintr+0xa2>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
801008e1:	e9 f7 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008e6:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008ec:	a1 24 18 11 80       	mov    0x80111824,%eax
801008f1:	39 c2                	cmp    %eax,%edx
801008f3:	0f 84 e4 00 00 00    	je     801009dd <consoleintr+0x1e4>
        input.e--;
801008f9:	a1 28 18 11 80       	mov    0x80111828,%eax
801008fe:	83 e8 01             	sub    $0x1,%eax
80100901:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
80100906:	83 ec 0c             	sub    $0xc,%esp
80100909:	68 00 01 00 00       	push   $0x100
8010090e:	e8 7f fe ff ff       	call   80100792 <consputc>
80100913:	83 c4 10             	add    $0x10,%esp
      }
      break;
80100916:	e9 c2 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    #ifdef CS333_P3P4
    case C('R'):
      rl = 1;
8010091b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      break;
80100922:	e9 b6 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('F'):
      fl = 1;
80100927:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
      break;
8010092e:	e9 aa 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('S'):
      sl = 1;
80100933:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
      break;
8010093a:	e9 9e 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    case C('Z'):
      zl = 1;
8010093f:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
80100946:	e9 92 00 00 00       	jmp    801009dd <consoleintr+0x1e4>
    #endif
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010094b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010094f:	0f 84 87 00 00 00    	je     801009dc <consoleintr+0x1e3>
80100955:	8b 15 28 18 11 80    	mov    0x80111828,%edx
8010095b:	a1 20 18 11 80       	mov    0x80111820,%eax
80100960:	29 c2                	sub    %eax,%edx
80100962:	89 d0                	mov    %edx,%eax
80100964:	83 f8 7f             	cmp    $0x7f,%eax
80100967:	77 73                	ja     801009dc <consoleintr+0x1e3>
        c = (c == '\r') ? '\n' : c;
80100969:	83 7d e0 0d          	cmpl   $0xd,-0x20(%ebp)
8010096d:	74 05                	je     80100974 <consoleintr+0x17b>
8010096f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100972:	eb 05                	jmp    80100979 <consoleintr+0x180>
80100974:	b8 0a 00 00 00       	mov    $0xa,%eax
80100979:	89 45 e0             	mov    %eax,-0x20(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010097c:	a1 28 18 11 80       	mov    0x80111828,%eax
80100981:	8d 50 01             	lea    0x1(%eax),%edx
80100984:	89 15 28 18 11 80    	mov    %edx,0x80111828
8010098a:	83 e0 7f             	and    $0x7f,%eax
8010098d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100990:	88 90 a0 17 11 80    	mov    %dl,-0x7feee860(%eax)
        consputc(c);
80100996:	83 ec 0c             	sub    $0xc,%esp
80100999:	ff 75 e0             	pushl  -0x20(%ebp)
8010099c:	e8 f1 fd ff ff       	call   80100792 <consputc>
801009a1:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009a4:	83 7d e0 0a          	cmpl   $0xa,-0x20(%ebp)
801009a8:	74 18                	je     801009c2 <consoleintr+0x1c9>
801009aa:	83 7d e0 04          	cmpl   $0x4,-0x20(%ebp)
801009ae:	74 12                	je     801009c2 <consoleintr+0x1c9>
801009b0:	a1 28 18 11 80       	mov    0x80111828,%eax
801009b5:	8b 15 20 18 11 80    	mov    0x80111820,%edx
801009bb:	83 ea 80             	sub    $0xffffff80,%edx
801009be:	39 d0                	cmp    %edx,%eax
801009c0:	75 1a                	jne    801009dc <consoleintr+0x1e3>
          input.w = input.e;
801009c2:	a1 28 18 11 80       	mov    0x80111828,%eax
801009c7:	a3 24 18 11 80       	mov    %eax,0x80111824
          wakeup(&input.r);
801009cc:	83 ec 0c             	sub    $0xc,%esp
801009cf:	68 20 18 11 80       	push   $0x80111820
801009d4:	e8 45 46 00 00       	call   8010501e <wakeup>
801009d9:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009dc:	90                   	nop
  #ifdef CS333_P3P4
  int rl = 0, fl = 0, sl = 0, zl = 0;
  #endif

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009dd:	8b 45 08             	mov    0x8(%ebp),%eax
801009e0:	ff d0                	call   *%eax
801009e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801009e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801009e9:	0f 89 48 fe ff ff    	jns    80100837 <consoleintr+0x3e>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009ef:	83 ec 0c             	sub    $0xc,%esp
801009f2:	68 e0 c5 10 80       	push   $0x8010c5e0
801009f7:	e8 1f 53 00 00       	call   80105d1b <release>
801009fc:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100a03:	74 07                	je     80100a0c <consoleintr+0x213>
    procdump();  // now call procdump() wo. cons.lock held
80100a05:	e8 06 49 00 00       	call   80105310 <procdump>
  else if (sl)
    display_sleeplist();
  else if (zl)
    display_zombielist();
  #endif
}
80100a0a:	eb 32                	jmp    80100a3e <consoleintr+0x245>
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
  #ifdef CS333_P3P4
  else if (rl)
80100a0c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100a10:	74 07                	je     80100a19 <consoleintr+0x220>
    display_readylist();
80100a12:	e8 bb 50 00 00       	call   80105ad2 <display_readylist>
  else if (sl)
    display_sleeplist();
  else if (zl)
    display_zombielist();
  #endif
}
80100a17:	eb 25                	jmp    80100a3e <consoleintr+0x245>
    procdump();  // now call procdump() wo. cons.lock held
  }
  #ifdef CS333_P3P4
  else if (rl)
    display_readylist();
  else if (fl)
80100a19:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100a1d:	74 07                	je     80100a26 <consoleintr+0x22d>
    display_freelist();
80100a1f:	e8 f8 50 00 00       	call   80105b1c <display_freelist>
  else if (sl)
    display_sleeplist();
  else if (zl)
    display_zombielist();
  #endif
}
80100a24:	eb 18                	jmp    80100a3e <consoleintr+0x245>
  #ifdef CS333_P3P4
  else if (rl)
    display_readylist();
  else if (fl)
    display_freelist();
  else if (sl)
80100a26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100a2a:	74 07                	je     80100a33 <consoleintr+0x23a>
    display_sleeplist();
80100a2c:	e8 2e 51 00 00       	call   80105b5f <display_sleeplist>
  else if (zl)
    display_zombielist();
  #endif
}
80100a31:	eb 0b                	jmp    80100a3e <consoleintr+0x245>
    display_readylist();
  else if (fl)
    display_freelist();
  else if (sl)
    display_sleeplist();
  else if (zl)
80100a33:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a37:	74 05                	je     80100a3e <consoleintr+0x245>
    display_zombielist();
80100a39:	e8 4b 51 00 00       	call   80105b89 <display_zombielist>
  #endif
}
80100a3e:	90                   	nop
80100a3f:	c9                   	leave  
80100a40:	c3                   	ret    

80100a41 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a41:	55                   	push   %ebp
80100a42:	89 e5                	mov    %esp,%ebp
80100a44:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100a47:	83 ec 0c             	sub    $0xc,%esp
80100a4a:	ff 75 08             	pushl  0x8(%ebp)
80100a4d:	e8 28 11 00 00       	call   80101b7a <iunlock>
80100a52:	83 c4 10             	add    $0x10,%esp
  target = n;
80100a55:	8b 45 10             	mov    0x10(%ebp),%eax
80100a58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a5b:	83 ec 0c             	sub    $0xc,%esp
80100a5e:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a63:	e8 4c 52 00 00       	call   80105cb4 <acquire>
80100a68:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a6b:	e9 ac 00 00 00       	jmp    80100b1c <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
80100a70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a76:	8b 40 24             	mov    0x24(%eax),%eax
80100a79:	85 c0                	test   %eax,%eax
80100a7b:	74 28                	je     80100aa5 <consoleread+0x64>
        release(&cons.lock);
80100a7d:	83 ec 0c             	sub    $0xc,%esp
80100a80:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a85:	e8 91 52 00 00       	call   80105d1b <release>
80100a8a:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a8d:	83 ec 0c             	sub    $0xc,%esp
80100a90:	ff 75 08             	pushl  0x8(%ebp)
80100a93:	e8 84 0f 00 00       	call   80101a1c <ilock>
80100a98:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100aa0:	e9 ab 00 00 00       	jmp    80100b50 <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100aa5:	83 ec 08             	sub    $0x8,%esp
80100aa8:	68 e0 c5 10 80       	push   $0x8010c5e0
80100aad:	68 20 18 11 80       	push   $0x80111820
80100ab2:	e8 52 44 00 00       	call   80104f09 <sleep>
80100ab7:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100aba:	8b 15 20 18 11 80    	mov    0x80111820,%edx
80100ac0:	a1 24 18 11 80       	mov    0x80111824,%eax
80100ac5:	39 c2                	cmp    %eax,%edx
80100ac7:	74 a7                	je     80100a70 <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ac9:	a1 20 18 11 80       	mov    0x80111820,%eax
80100ace:	8d 50 01             	lea    0x1(%eax),%edx
80100ad1:	89 15 20 18 11 80    	mov    %edx,0x80111820
80100ad7:	83 e0 7f             	and    $0x7f,%eax
80100ada:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
80100ae1:	0f be c0             	movsbl %al,%eax
80100ae4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100ae7:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100aeb:	75 17                	jne    80100b04 <consoleread+0xc3>
      if(n < target){
80100aed:	8b 45 10             	mov    0x10(%ebp),%eax
80100af0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100af3:	73 2f                	jae    80100b24 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100af5:	a1 20 18 11 80       	mov    0x80111820,%eax
80100afa:	83 e8 01             	sub    $0x1,%eax
80100afd:	a3 20 18 11 80       	mov    %eax,0x80111820
      }
      break;
80100b02:	eb 20                	jmp    80100b24 <consoleread+0xe3>
    }
    *dst++ = c;
80100b04:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b07:	8d 50 01             	lea    0x1(%eax),%edx
80100b0a:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b10:	88 10                	mov    %dl,(%eax)
    --n;
80100b12:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100b16:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b1a:	74 0b                	je     80100b27 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b20:	7f 98                	jg     80100aba <consoleread+0x79>
80100b22:	eb 04                	jmp    80100b28 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100b24:	90                   	nop
80100b25:	eb 01                	jmp    80100b28 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100b27:	90                   	nop
  }
  release(&cons.lock);
80100b28:	83 ec 0c             	sub    $0xc,%esp
80100b2b:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b30:	e8 e6 51 00 00       	call   80105d1b <release>
80100b35:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b38:	83 ec 0c             	sub    $0xc,%esp
80100b3b:	ff 75 08             	pushl  0x8(%ebp)
80100b3e:	e8 d9 0e 00 00       	call   80101a1c <ilock>
80100b43:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100b46:	8b 45 10             	mov    0x10(%ebp),%eax
80100b49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b4c:	29 c2                	sub    %eax,%edx
80100b4e:	89 d0                	mov    %edx,%eax
}
80100b50:	c9                   	leave  
80100b51:	c3                   	ret    

80100b52 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b52:	55                   	push   %ebp
80100b53:	89 e5                	mov    %esp,%ebp
80100b55:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b58:	83 ec 0c             	sub    $0xc,%esp
80100b5b:	ff 75 08             	pushl  0x8(%ebp)
80100b5e:	e8 17 10 00 00       	call   80101b7a <iunlock>
80100b63:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b66:	83 ec 0c             	sub    $0xc,%esp
80100b69:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b6e:	e8 41 51 00 00       	call   80105cb4 <acquire>
80100b73:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b7d:	eb 21                	jmp    80100ba0 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100b7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b82:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b85:	01 d0                	add    %edx,%eax
80100b87:	0f b6 00             	movzbl (%eax),%eax
80100b8a:	0f be c0             	movsbl %al,%eax
80100b8d:	0f b6 c0             	movzbl %al,%eax
80100b90:	83 ec 0c             	sub    $0xc,%esp
80100b93:	50                   	push   %eax
80100b94:	e8 f9 fb ff ff       	call   80100792 <consputc>
80100b99:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100b9c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ba3:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ba6:	7c d7                	jl     80100b7f <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ba8:	83 ec 0c             	sub    $0xc,%esp
80100bab:	68 e0 c5 10 80       	push   $0x8010c5e0
80100bb0:	e8 66 51 00 00       	call   80105d1b <release>
80100bb5:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100bb8:	83 ec 0c             	sub    $0xc,%esp
80100bbb:	ff 75 08             	pushl  0x8(%ebp)
80100bbe:	e8 59 0e 00 00       	call   80101a1c <ilock>
80100bc3:	83 c4 10             	add    $0x10,%esp

  return n;
80100bc6:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bc9:	c9                   	leave  
80100bca:	c3                   	ret    

80100bcb <consoleinit>:

void
consoleinit(void)
{
80100bcb:	55                   	push   %ebp
80100bcc:	89 e5                	mov    %esp,%ebp
80100bce:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100bd1:	83 ec 08             	sub    $0x8,%esp
80100bd4:	68 96 93 10 80       	push   $0x80109396
80100bd9:	68 e0 c5 10 80       	push   $0x8010c5e0
80100bde:	e8 af 50 00 00       	call   80105c92 <initlock>
80100be3:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100be6:	c7 05 ec 21 11 80 52 	movl   $0x80100b52,0x801121ec
80100bed:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bf0:	c7 05 e8 21 11 80 41 	movl   $0x80100a41,0x801121e8
80100bf7:	0a 10 80 
  cons.locking = 1;
80100bfa:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100c01:	00 00 00 

  picenable(IRQ_KBD);
80100c04:	83 ec 0c             	sub    $0xc,%esp
80100c07:	6a 01                	push   $0x1
80100c09:	e8 cf 33 00 00       	call   80103fdd <picenable>
80100c0e:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100c11:	83 ec 08             	sub    $0x8,%esp
80100c14:	6a 00                	push   $0x0
80100c16:	6a 01                	push   $0x1
80100c18:	e8 6f 1f 00 00       	call   80102b8c <ioapicenable>
80100c1d:	83 c4 10             	add    $0x10,%esp
}
80100c20:	90                   	nop
80100c21:	c9                   	leave  
80100c22:	c3                   	ret    

80100c23 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c23:	55                   	push   %ebp
80100c24:	89 e5                	mov    %esp,%ebp
80100c26:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100c2c:	e8 ce 29 00 00       	call   801035ff <begin_op>
  if((ip = namei(path)) == 0){
80100c31:	83 ec 0c             	sub    $0xc,%esp
80100c34:	ff 75 08             	pushl  0x8(%ebp)
80100c37:	e8 9e 19 00 00       	call   801025da <namei>
80100c3c:	83 c4 10             	add    $0x10,%esp
80100c3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c42:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c46:	75 0f                	jne    80100c57 <exec+0x34>
    end_op();
80100c48:	e8 3e 2a 00 00       	call   8010368b <end_op>
    return -1;
80100c4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c52:	e9 ce 03 00 00       	jmp    80101025 <exec+0x402>
  }
  ilock(ip);
80100c57:	83 ec 0c             	sub    $0xc,%esp
80100c5a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c5d:	e8 ba 0d 00 00       	call   80101a1c <ilock>
80100c62:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c65:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100c6c:	6a 34                	push   $0x34
80100c6e:	6a 00                	push   $0x0
80100c70:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c76:	50                   	push   %eax
80100c77:	ff 75 d8             	pushl  -0x28(%ebp)
80100c7a:	e8 0b 13 00 00       	call   80101f8a <readi>
80100c7f:	83 c4 10             	add    $0x10,%esp
80100c82:	83 f8 33             	cmp    $0x33,%eax
80100c85:	0f 86 49 03 00 00    	jbe    80100fd4 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c8b:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c91:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c96:	0f 85 3b 03 00 00    	jne    80100fd7 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c9c:	e8 74 7e 00 00       	call   80108b15 <setupkvm>
80100ca1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ca4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ca8:	0f 84 2c 03 00 00    	je     80100fda <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100cae:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb5:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cbc:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100cc2:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc5:	e9 ab 00 00 00       	jmp    80100d75 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ccd:	6a 20                	push   $0x20
80100ccf:	50                   	push   %eax
80100cd0:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100cd6:	50                   	push   %eax
80100cd7:	ff 75 d8             	pushl  -0x28(%ebp)
80100cda:	e8 ab 12 00 00       	call   80101f8a <readi>
80100cdf:	83 c4 10             	add    $0x10,%esp
80100ce2:	83 f8 20             	cmp    $0x20,%eax
80100ce5:	0f 85 f2 02 00 00    	jne    80100fdd <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ceb:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cf1:	83 f8 01             	cmp    $0x1,%eax
80100cf4:	75 71                	jne    80100d67 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100cf6:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100cfc:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d02:	39 c2                	cmp    %eax,%edx
80100d04:	0f 82 d6 02 00 00    	jb     80100fe0 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d0a:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100d10:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100d16:	01 d0                	add    %edx,%eax
80100d18:	83 ec 04             	sub    $0x4,%esp
80100d1b:	50                   	push   %eax
80100d1c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d1f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d22:	e8 95 81 00 00       	call   80108ebc <allocuvm>
80100d27:	83 c4 10             	add    $0x10,%esp
80100d2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d2d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d31:	0f 84 ac 02 00 00    	je     80100fe3 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d37:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d3d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d43:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100d49:	83 ec 0c             	sub    $0xc,%esp
80100d4c:	52                   	push   %edx
80100d4d:	50                   	push   %eax
80100d4e:	ff 75 d8             	pushl  -0x28(%ebp)
80100d51:	51                   	push   %ecx
80100d52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d55:	e8 8b 80 00 00       	call   80108de5 <loaduvm>
80100d5a:	83 c4 20             	add    $0x20,%esp
80100d5d:	85 c0                	test   %eax,%eax
80100d5f:	0f 88 81 02 00 00    	js     80100fe6 <exec+0x3c3>
80100d65:	eb 01                	jmp    80100d68 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100d67:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d68:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d6f:	83 c0 20             	add    $0x20,%eax
80100d72:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d75:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d7c:	0f b7 c0             	movzwl %ax,%eax
80100d7f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100d82:	0f 8f 42 ff ff ff    	jg     80100cca <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100d88:	83 ec 0c             	sub    $0xc,%esp
80100d8b:	ff 75 d8             	pushl  -0x28(%ebp)
80100d8e:	e8 49 0f 00 00       	call   80101cdc <iunlockput>
80100d93:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d96:	e8 f0 28 00 00       	call   8010368b <end_op>
  ip = 0;
80100d9b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	05 ff 0f 00 00       	add    $0xfff,%eax
80100daa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100daf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100db2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db5:	05 00 20 00 00       	add    $0x2000,%eax
80100dba:	83 ec 04             	sub    $0x4,%esp
80100dbd:	50                   	push   %eax
80100dbe:	ff 75 e0             	pushl  -0x20(%ebp)
80100dc1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc4:	e8 f3 80 00 00       	call   80108ebc <allocuvm>
80100dc9:	83 c4 10             	add    $0x10,%esp
80100dcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100dcf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100dd3:	0f 84 10 02 00 00    	je     80100fe9 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100dd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ddc:	2d 00 20 00 00       	sub    $0x2000,%eax
80100de1:	83 ec 08             	sub    $0x8,%esp
80100de4:	50                   	push   %eax
80100de5:	ff 75 d4             	pushl  -0x2c(%ebp)
80100de8:	e8 f5 82 00 00       	call   801090e2 <clearpteu>
80100ded:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100df0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100df3:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100df6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100dfd:	e9 96 00 00 00       	jmp    80100e98 <exec+0x275>
    if(argc >= MAXARG)
80100e02:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e06:	0f 87 e0 01 00 00    	ja     80100fec <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e16:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e19:	01 d0                	add    %edx,%eax
80100e1b:	8b 00                	mov    (%eax),%eax
80100e1d:	83 ec 0c             	sub    $0xc,%esp
80100e20:	50                   	push   %eax
80100e21:	e8 3e 53 00 00       	call   80106164 <strlen>
80100e26:	83 c4 10             	add    $0x10,%esp
80100e29:	89 c2                	mov    %eax,%edx
80100e2b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e2e:	29 d0                	sub    %edx,%eax
80100e30:	83 e8 01             	sub    $0x1,%eax
80100e33:	83 e0 fc             	and    $0xfffffffc,%eax
80100e36:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e43:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e46:	01 d0                	add    %edx,%eax
80100e48:	8b 00                	mov    (%eax),%eax
80100e4a:	83 ec 0c             	sub    $0xc,%esp
80100e4d:	50                   	push   %eax
80100e4e:	e8 11 53 00 00       	call   80106164 <strlen>
80100e53:	83 c4 10             	add    $0x10,%esp
80100e56:	83 c0 01             	add    $0x1,%eax
80100e59:	89 c1                	mov    %eax,%ecx
80100e5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e5e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e65:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e68:	01 d0                	add    %edx,%eax
80100e6a:	8b 00                	mov    (%eax),%eax
80100e6c:	51                   	push   %ecx
80100e6d:	50                   	push   %eax
80100e6e:	ff 75 dc             	pushl  -0x24(%ebp)
80100e71:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e74:	e8 20 84 00 00       	call   80109299 <copyout>
80100e79:	83 c4 10             	add    $0x10,%esp
80100e7c:	85 c0                	test   %eax,%eax
80100e7e:	0f 88 6b 01 00 00    	js     80100fef <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e87:	8d 50 03             	lea    0x3(%eax),%edx
80100e8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e8d:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e94:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea5:	01 d0                	add    %edx,%eax
80100ea7:	8b 00                	mov    (%eax),%eax
80100ea9:	85 c0                	test   %eax,%eax
80100eab:	0f 85 51 ff ff ff    	jne    80100e02 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100eb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb4:	83 c0 03             	add    $0x3,%eax
80100eb7:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100ebe:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100ec2:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100ec9:	ff ff ff 
  ustack[1] = argc;
80100ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ecf:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100ed5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ed8:	83 c0 01             	add    $0x1,%eax
80100edb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ee2:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee5:	29 d0                	sub    %edx,%eax
80100ee7:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef0:	83 c0 04             	add    $0x4,%eax
80100ef3:	c1 e0 02             	shl    $0x2,%eax
80100ef6:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100ef9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100efc:	83 c0 04             	add    $0x4,%eax
80100eff:	c1 e0 02             	shl    $0x2,%eax
80100f02:	50                   	push   %eax
80100f03:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100f09:	50                   	push   %eax
80100f0a:	ff 75 dc             	pushl  -0x24(%ebp)
80100f0d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f10:	e8 84 83 00 00       	call   80109299 <copyout>
80100f15:	83 c4 10             	add    $0x10,%esp
80100f18:	85 c0                	test   %eax,%eax
80100f1a:	0f 88 d2 00 00 00    	js     80100ff2 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f20:	8b 45 08             	mov    0x8(%ebp),%eax
80100f23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f2c:	eb 17                	jmp    80100f45 <exec+0x322>
    if(*s == '/')
80100f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f31:	0f b6 00             	movzbl (%eax),%eax
80100f34:	3c 2f                	cmp    $0x2f,%al
80100f36:	75 09                	jne    80100f41 <exec+0x31e>
      last = s+1;
80100f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f3b:	83 c0 01             	add    $0x1,%eax
80100f3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f41:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100f45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f48:	0f b6 00             	movzbl (%eax),%eax
80100f4b:	84 c0                	test   %al,%al
80100f4d:	75 df                	jne    80100f2e <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f55:	83 c0 6c             	add    $0x6c,%eax
80100f58:	83 ec 04             	sub    $0x4,%esp
80100f5b:	6a 10                	push   $0x10
80100f5d:	ff 75 f0             	pushl  -0x10(%ebp)
80100f60:	50                   	push   %eax
80100f61:	e8 b4 51 00 00       	call   8010611a <safestrcpy>
80100f66:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100f69:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f6f:	8b 40 04             	mov    0x4(%eax),%eax
80100f72:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f75:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f7b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f7e:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f81:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f87:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f8a:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f92:	8b 40 18             	mov    0x18(%eax),%eax
80100f95:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f9b:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f9e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fa4:	8b 40 18             	mov    0x18(%eax),%eax
80100fa7:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100faa:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100fad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100fb3:	83 ec 0c             	sub    $0xc,%esp
80100fb6:	50                   	push   %eax
80100fb7:	e8 40 7c 00 00       	call   80108bfc <switchuvm>
80100fbc:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100fbf:	83 ec 0c             	sub    $0xc,%esp
80100fc2:	ff 75 d0             	pushl  -0x30(%ebp)
80100fc5:	e8 78 80 00 00       	call   80109042 <freevm>
80100fca:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fcd:	b8 00 00 00 00       	mov    $0x0,%eax
80100fd2:	eb 51                	jmp    80101025 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100fd4:	90                   	nop
80100fd5:	eb 1c                	jmp    80100ff3 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100fd7:	90                   	nop
80100fd8:	eb 19                	jmp    80100ff3 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100fda:	90                   	nop
80100fdb:	eb 16                	jmp    80100ff3 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100fdd:	90                   	nop
80100fde:	eb 13                	jmp    80100ff3 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100fe0:	90                   	nop
80100fe1:	eb 10                	jmp    80100ff3 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100fe3:	90                   	nop
80100fe4:	eb 0d                	jmp    80100ff3 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100fe6:	90                   	nop
80100fe7:	eb 0a                	jmp    80100ff3 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100fe9:	90                   	nop
80100fea:	eb 07                	jmp    80100ff3 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100fec:	90                   	nop
80100fed:	eb 04                	jmp    80100ff3 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100fef:	90                   	nop
80100ff0:	eb 01                	jmp    80100ff3 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100ff2:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100ff3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ff7:	74 0e                	je     80101007 <exec+0x3e4>
    freevm(pgdir);
80100ff9:	83 ec 0c             	sub    $0xc,%esp
80100ffc:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fff:	e8 3e 80 00 00       	call   80109042 <freevm>
80101004:	83 c4 10             	add    $0x10,%esp
  if(ip){
80101007:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010100b:	74 13                	je     80101020 <exec+0x3fd>
    iunlockput(ip);
8010100d:	83 ec 0c             	sub    $0xc,%esp
80101010:	ff 75 d8             	pushl  -0x28(%ebp)
80101013:	e8 c4 0c 00 00       	call   80101cdc <iunlockput>
80101018:	83 c4 10             	add    $0x10,%esp
    end_op();
8010101b:	e8 6b 26 00 00       	call   8010368b <end_op>
  }
  return -1;
80101020:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101025:	c9                   	leave  
80101026:	c3                   	ret    

80101027 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101027:	55                   	push   %ebp
80101028:	89 e5                	mov    %esp,%ebp
8010102a:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
8010102d:	83 ec 08             	sub    $0x8,%esp
80101030:	68 9e 93 10 80       	push   $0x8010939e
80101035:	68 40 18 11 80       	push   $0x80111840
8010103a:	e8 53 4c 00 00       	call   80105c92 <initlock>
8010103f:	83 c4 10             	add    $0x10,%esp
}
80101042:	90                   	nop
80101043:	c9                   	leave  
80101044:	c3                   	ret    

80101045 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101045:	55                   	push   %ebp
80101046:	89 e5                	mov    %esp,%ebp
80101048:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
8010104b:	83 ec 0c             	sub    $0xc,%esp
8010104e:	68 40 18 11 80       	push   $0x80111840
80101053:	e8 5c 4c 00 00       	call   80105cb4 <acquire>
80101058:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010105b:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
80101062:	eb 2d                	jmp    80101091 <filealloc+0x4c>
    if(f->ref == 0){
80101064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101067:	8b 40 04             	mov    0x4(%eax),%eax
8010106a:	85 c0                	test   %eax,%eax
8010106c:	75 1f                	jne    8010108d <filealloc+0x48>
      f->ref = 1;
8010106e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101071:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	68 40 18 11 80       	push   $0x80111840
80101080:	e8 96 4c 00 00       	call   80105d1b <release>
80101085:	83 c4 10             	add    $0x10,%esp
      return f;
80101088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010108b:	eb 23                	jmp    801010b0 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010108d:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101091:	b8 d4 21 11 80       	mov    $0x801121d4,%eax
80101096:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101099:	72 c9                	jb     80101064 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010109b:	83 ec 0c             	sub    $0xc,%esp
8010109e:	68 40 18 11 80       	push   $0x80111840
801010a3:	e8 73 4c 00 00       	call   80105d1b <release>
801010a8:	83 c4 10             	add    $0x10,%esp
  return 0;
801010ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010b0:	c9                   	leave  
801010b1:	c3                   	ret    

801010b2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010b2:	55                   	push   %ebp
801010b3:	89 e5                	mov    %esp,%ebp
801010b5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
801010b8:	83 ec 0c             	sub    $0xc,%esp
801010bb:	68 40 18 11 80       	push   $0x80111840
801010c0:	e8 ef 4b 00 00       	call   80105cb4 <acquire>
801010c5:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010c8:	8b 45 08             	mov    0x8(%ebp),%eax
801010cb:	8b 40 04             	mov    0x4(%eax),%eax
801010ce:	85 c0                	test   %eax,%eax
801010d0:	7f 0d                	jg     801010df <filedup+0x2d>
    panic("filedup");
801010d2:	83 ec 0c             	sub    $0xc,%esp
801010d5:	68 a5 93 10 80       	push   $0x801093a5
801010da:	e8 87 f4 ff ff       	call   80100566 <panic>
  f->ref++;
801010df:	8b 45 08             	mov    0x8(%ebp),%eax
801010e2:	8b 40 04             	mov    0x4(%eax),%eax
801010e5:	8d 50 01             	lea    0x1(%eax),%edx
801010e8:	8b 45 08             	mov    0x8(%ebp),%eax
801010eb:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010ee:	83 ec 0c             	sub    $0xc,%esp
801010f1:	68 40 18 11 80       	push   $0x80111840
801010f6:	e8 20 4c 00 00       	call   80105d1b <release>
801010fb:	83 c4 10             	add    $0x10,%esp
  return f;
801010fe:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101101:	c9                   	leave  
80101102:	c3                   	ret    

80101103 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101103:	55                   	push   %ebp
80101104:	89 e5                	mov    %esp,%ebp
80101106:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101109:	83 ec 0c             	sub    $0xc,%esp
8010110c:	68 40 18 11 80       	push   $0x80111840
80101111:	e8 9e 4b 00 00       	call   80105cb4 <acquire>
80101116:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101119:	8b 45 08             	mov    0x8(%ebp),%eax
8010111c:	8b 40 04             	mov    0x4(%eax),%eax
8010111f:	85 c0                	test   %eax,%eax
80101121:	7f 0d                	jg     80101130 <fileclose+0x2d>
    panic("fileclose");
80101123:	83 ec 0c             	sub    $0xc,%esp
80101126:	68 ad 93 10 80       	push   $0x801093ad
8010112b:	e8 36 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101130:	8b 45 08             	mov    0x8(%ebp),%eax
80101133:	8b 40 04             	mov    0x4(%eax),%eax
80101136:	8d 50 ff             	lea    -0x1(%eax),%edx
80101139:	8b 45 08             	mov    0x8(%ebp),%eax
8010113c:	89 50 04             	mov    %edx,0x4(%eax)
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
80101142:	8b 40 04             	mov    0x4(%eax),%eax
80101145:	85 c0                	test   %eax,%eax
80101147:	7e 15                	jle    8010115e <fileclose+0x5b>
    release(&ftable.lock);
80101149:	83 ec 0c             	sub    $0xc,%esp
8010114c:	68 40 18 11 80       	push   $0x80111840
80101151:	e8 c5 4b 00 00       	call   80105d1b <release>
80101156:	83 c4 10             	add    $0x10,%esp
80101159:	e9 8b 00 00 00       	jmp    801011e9 <fileclose+0xe6>
    return;
  }
  ff = *f;
8010115e:	8b 45 08             	mov    0x8(%ebp),%eax
80101161:	8b 10                	mov    (%eax),%edx
80101163:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101166:	8b 50 04             	mov    0x4(%eax),%edx
80101169:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010116c:	8b 50 08             	mov    0x8(%eax),%edx
8010116f:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101172:	8b 50 0c             	mov    0xc(%eax),%edx
80101175:	89 55 ec             	mov    %edx,-0x14(%ebp)
80101178:	8b 50 10             	mov    0x10(%eax),%edx
8010117b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010117e:	8b 40 14             	mov    0x14(%eax),%eax
80101181:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101184:	8b 45 08             	mov    0x8(%ebp),%eax
80101187:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010118e:	8b 45 08             	mov    0x8(%ebp),%eax
80101191:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101197:	83 ec 0c             	sub    $0xc,%esp
8010119a:	68 40 18 11 80       	push   $0x80111840
8010119f:	e8 77 4b 00 00       	call   80105d1b <release>
801011a4:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801011a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011aa:	83 f8 01             	cmp    $0x1,%eax
801011ad:	75 19                	jne    801011c8 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801011af:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801011b3:	0f be d0             	movsbl %al,%edx
801011b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801011b9:	83 ec 08             	sub    $0x8,%esp
801011bc:	52                   	push   %edx
801011bd:	50                   	push   %eax
801011be:	e8 83 30 00 00       	call   80104246 <pipeclose>
801011c3:	83 c4 10             	add    $0x10,%esp
801011c6:	eb 21                	jmp    801011e9 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801011c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011cb:	83 f8 02             	cmp    $0x2,%eax
801011ce:	75 19                	jne    801011e9 <fileclose+0xe6>
    begin_op();
801011d0:	e8 2a 24 00 00       	call   801035ff <begin_op>
    iput(ff.ip);
801011d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801011d8:	83 ec 0c             	sub    $0xc,%esp
801011db:	50                   	push   %eax
801011dc:	e8 0b 0a 00 00       	call   80101bec <iput>
801011e1:	83 c4 10             	add    $0x10,%esp
    end_op();
801011e4:	e8 a2 24 00 00       	call   8010368b <end_op>
  }
}
801011e9:	c9                   	leave  
801011ea:	c3                   	ret    

801011eb <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011eb:	55                   	push   %ebp
801011ec:	89 e5                	mov    %esp,%ebp
801011ee:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011f1:	8b 45 08             	mov    0x8(%ebp),%eax
801011f4:	8b 00                	mov    (%eax),%eax
801011f6:	83 f8 02             	cmp    $0x2,%eax
801011f9:	75 40                	jne    8010123b <filestat+0x50>
    ilock(f->ip);
801011fb:	8b 45 08             	mov    0x8(%ebp),%eax
801011fe:	8b 40 10             	mov    0x10(%eax),%eax
80101201:	83 ec 0c             	sub    $0xc,%esp
80101204:	50                   	push   %eax
80101205:	e8 12 08 00 00       	call   80101a1c <ilock>
8010120a:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010120d:	8b 45 08             	mov    0x8(%ebp),%eax
80101210:	8b 40 10             	mov    0x10(%eax),%eax
80101213:	83 ec 08             	sub    $0x8,%esp
80101216:	ff 75 0c             	pushl  0xc(%ebp)
80101219:	50                   	push   %eax
8010121a:	e8 25 0d 00 00       	call   80101f44 <stati>
8010121f:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101222:	8b 45 08             	mov    0x8(%ebp),%eax
80101225:	8b 40 10             	mov    0x10(%eax),%eax
80101228:	83 ec 0c             	sub    $0xc,%esp
8010122b:	50                   	push   %eax
8010122c:	e8 49 09 00 00       	call   80101b7a <iunlock>
80101231:	83 c4 10             	add    $0x10,%esp
    return 0;
80101234:	b8 00 00 00 00       	mov    $0x0,%eax
80101239:	eb 05                	jmp    80101240 <filestat+0x55>
  }
  return -1;
8010123b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101240:	c9                   	leave  
80101241:	c3                   	ret    

80101242 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101242:	55                   	push   %ebp
80101243:	89 e5                	mov    %esp,%ebp
80101245:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010124f:	84 c0                	test   %al,%al
80101251:	75 0a                	jne    8010125d <fileread+0x1b>
    return -1;
80101253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101258:	e9 9b 00 00 00       	jmp    801012f8 <fileread+0xb6>
  if(f->type == FD_PIPE)
8010125d:	8b 45 08             	mov    0x8(%ebp),%eax
80101260:	8b 00                	mov    (%eax),%eax
80101262:	83 f8 01             	cmp    $0x1,%eax
80101265:	75 1a                	jne    80101281 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101267:	8b 45 08             	mov    0x8(%ebp),%eax
8010126a:	8b 40 0c             	mov    0xc(%eax),%eax
8010126d:	83 ec 04             	sub    $0x4,%esp
80101270:	ff 75 10             	pushl  0x10(%ebp)
80101273:	ff 75 0c             	pushl  0xc(%ebp)
80101276:	50                   	push   %eax
80101277:	e8 72 31 00 00       	call   801043ee <piperead>
8010127c:	83 c4 10             	add    $0x10,%esp
8010127f:	eb 77                	jmp    801012f8 <fileread+0xb6>
  if(f->type == FD_INODE){
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	8b 00                	mov    (%eax),%eax
80101286:	83 f8 02             	cmp    $0x2,%eax
80101289:	75 60                	jne    801012eb <fileread+0xa9>
    ilock(f->ip);
8010128b:	8b 45 08             	mov    0x8(%ebp),%eax
8010128e:	8b 40 10             	mov    0x10(%eax),%eax
80101291:	83 ec 0c             	sub    $0xc,%esp
80101294:	50                   	push   %eax
80101295:	e8 82 07 00 00       	call   80101a1c <ilock>
8010129a:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010129d:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012a0:	8b 45 08             	mov    0x8(%ebp),%eax
801012a3:	8b 50 14             	mov    0x14(%eax),%edx
801012a6:	8b 45 08             	mov    0x8(%ebp),%eax
801012a9:	8b 40 10             	mov    0x10(%eax),%eax
801012ac:	51                   	push   %ecx
801012ad:	52                   	push   %edx
801012ae:	ff 75 0c             	pushl  0xc(%ebp)
801012b1:	50                   	push   %eax
801012b2:	e8 d3 0c 00 00       	call   80101f8a <readi>
801012b7:	83 c4 10             	add    $0x10,%esp
801012ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012c1:	7e 11                	jle    801012d4 <fileread+0x92>
      f->off += r;
801012c3:	8b 45 08             	mov    0x8(%ebp),%eax
801012c6:	8b 50 14             	mov    0x14(%eax),%edx
801012c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012cc:	01 c2                	add    %eax,%edx
801012ce:	8b 45 08             	mov    0x8(%ebp),%eax
801012d1:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012d4:	8b 45 08             	mov    0x8(%ebp),%eax
801012d7:	8b 40 10             	mov    0x10(%eax),%eax
801012da:	83 ec 0c             	sub    $0xc,%esp
801012dd:	50                   	push   %eax
801012de:	e8 97 08 00 00       	call   80101b7a <iunlock>
801012e3:	83 c4 10             	add    $0x10,%esp
    return r;
801012e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012e9:	eb 0d                	jmp    801012f8 <fileread+0xb6>
  }
  panic("fileread");
801012eb:	83 ec 0c             	sub    $0xc,%esp
801012ee:	68 b7 93 10 80       	push   $0x801093b7
801012f3:	e8 6e f2 ff ff       	call   80100566 <panic>
}
801012f8:	c9                   	leave  
801012f9:	c3                   	ret    

801012fa <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012fa:	55                   	push   %ebp
801012fb:	89 e5                	mov    %esp,%ebp
801012fd:	53                   	push   %ebx
801012fe:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101301:	8b 45 08             	mov    0x8(%ebp),%eax
80101304:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101308:	84 c0                	test   %al,%al
8010130a:	75 0a                	jne    80101316 <filewrite+0x1c>
    return -1;
8010130c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101311:	e9 1b 01 00 00       	jmp    80101431 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101316:	8b 45 08             	mov    0x8(%ebp),%eax
80101319:	8b 00                	mov    (%eax),%eax
8010131b:	83 f8 01             	cmp    $0x1,%eax
8010131e:	75 1d                	jne    8010133d <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101320:	8b 45 08             	mov    0x8(%ebp),%eax
80101323:	8b 40 0c             	mov    0xc(%eax),%eax
80101326:	83 ec 04             	sub    $0x4,%esp
80101329:	ff 75 10             	pushl  0x10(%ebp)
8010132c:	ff 75 0c             	pushl  0xc(%ebp)
8010132f:	50                   	push   %eax
80101330:	e8 bb 2f 00 00       	call   801042f0 <pipewrite>
80101335:	83 c4 10             	add    $0x10,%esp
80101338:	e9 f4 00 00 00       	jmp    80101431 <filewrite+0x137>
  if(f->type == FD_INODE){
8010133d:	8b 45 08             	mov    0x8(%ebp),%eax
80101340:	8b 00                	mov    (%eax),%eax
80101342:	83 f8 02             	cmp    $0x2,%eax
80101345:	0f 85 d9 00 00 00    	jne    80101424 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010134b:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101359:	e9 a3 00 00 00       	jmp    80101401 <filewrite+0x107>
      int n1 = n - i;
8010135e:	8b 45 10             	mov    0x10(%ebp),%eax
80101361:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101364:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101367:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010136a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010136d:	7e 06                	jle    80101375 <filewrite+0x7b>
        n1 = max;
8010136f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101372:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101375:	e8 85 22 00 00       	call   801035ff <begin_op>
      ilock(f->ip);
8010137a:	8b 45 08             	mov    0x8(%ebp),%eax
8010137d:	8b 40 10             	mov    0x10(%eax),%eax
80101380:	83 ec 0c             	sub    $0xc,%esp
80101383:	50                   	push   %eax
80101384:	e8 93 06 00 00       	call   80101a1c <ilock>
80101389:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010138c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010138f:	8b 45 08             	mov    0x8(%ebp),%eax
80101392:	8b 50 14             	mov    0x14(%eax),%edx
80101395:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101398:	8b 45 0c             	mov    0xc(%ebp),%eax
8010139b:	01 c3                	add    %eax,%ebx
8010139d:	8b 45 08             	mov    0x8(%ebp),%eax
801013a0:	8b 40 10             	mov    0x10(%eax),%eax
801013a3:	51                   	push   %ecx
801013a4:	52                   	push   %edx
801013a5:	53                   	push   %ebx
801013a6:	50                   	push   %eax
801013a7:	e8 35 0d 00 00       	call   801020e1 <writei>
801013ac:	83 c4 10             	add    $0x10,%esp
801013af:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013b2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013b6:	7e 11                	jle    801013c9 <filewrite+0xcf>
        f->off += r;
801013b8:	8b 45 08             	mov    0x8(%ebp),%eax
801013bb:	8b 50 14             	mov    0x14(%eax),%edx
801013be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013c1:	01 c2                	add    %eax,%edx
801013c3:	8b 45 08             	mov    0x8(%ebp),%eax
801013c6:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013c9:	8b 45 08             	mov    0x8(%ebp),%eax
801013cc:	8b 40 10             	mov    0x10(%eax),%eax
801013cf:	83 ec 0c             	sub    $0xc,%esp
801013d2:	50                   	push   %eax
801013d3:	e8 a2 07 00 00       	call   80101b7a <iunlock>
801013d8:	83 c4 10             	add    $0x10,%esp
      end_op();
801013db:	e8 ab 22 00 00       	call   8010368b <end_op>

      if(r < 0)
801013e0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013e4:	78 29                	js     8010140f <filewrite+0x115>
        break;
      if(r != n1)
801013e6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013e9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013ec:	74 0d                	je     801013fb <filewrite+0x101>
        panic("short filewrite");
801013ee:	83 ec 0c             	sub    $0xc,%esp
801013f1:	68 c0 93 10 80       	push   $0x801093c0
801013f6:	e8 6b f1 ff ff       	call   80100566 <panic>
      i += r;
801013fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013fe:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101404:	3b 45 10             	cmp    0x10(%ebp),%eax
80101407:	0f 8c 51 ff ff ff    	jl     8010135e <filewrite+0x64>
8010140d:	eb 01                	jmp    80101410 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010140f:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101413:	3b 45 10             	cmp    0x10(%ebp),%eax
80101416:	75 05                	jne    8010141d <filewrite+0x123>
80101418:	8b 45 10             	mov    0x10(%ebp),%eax
8010141b:	eb 14                	jmp    80101431 <filewrite+0x137>
8010141d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101422:	eb 0d                	jmp    80101431 <filewrite+0x137>
  }
  panic("filewrite");
80101424:	83 ec 0c             	sub    $0xc,%esp
80101427:	68 d0 93 10 80       	push   $0x801093d0
8010142c:	e8 35 f1 ff ff       	call   80100566 <panic>
}
80101431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101434:	c9                   	leave  
80101435:	c3                   	ret    

80101436 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101436:	55                   	push   %ebp
80101437:	89 e5                	mov    %esp,%ebp
80101439:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010143c:	8b 45 08             	mov    0x8(%ebp),%eax
8010143f:	83 ec 08             	sub    $0x8,%esp
80101442:	6a 01                	push   $0x1
80101444:	50                   	push   %eax
80101445:	e8 6c ed ff ff       	call   801001b6 <bread>
8010144a:	83 c4 10             	add    $0x10,%esp
8010144d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101453:	83 c0 18             	add    $0x18,%eax
80101456:	83 ec 04             	sub    $0x4,%esp
80101459:	6a 1c                	push   $0x1c
8010145b:	50                   	push   %eax
8010145c:	ff 75 0c             	pushl  0xc(%ebp)
8010145f:	e8 72 4b 00 00       	call   80105fd6 <memmove>
80101464:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101467:	83 ec 0c             	sub    $0xc,%esp
8010146a:	ff 75 f4             	pushl  -0xc(%ebp)
8010146d:	e8 bc ed ff ff       	call   8010022e <brelse>
80101472:	83 c4 10             	add    $0x10,%esp
}
80101475:	90                   	nop
80101476:	c9                   	leave  
80101477:	c3                   	ret    

80101478 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101478:	55                   	push   %ebp
80101479:	89 e5                	mov    %esp,%ebp
8010147b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
8010147e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101481:	8b 45 08             	mov    0x8(%ebp),%eax
80101484:	83 ec 08             	sub    $0x8,%esp
80101487:	52                   	push   %edx
80101488:	50                   	push   %eax
80101489:	e8 28 ed ff ff       	call   801001b6 <bread>
8010148e:	83 c4 10             	add    $0x10,%esp
80101491:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101497:	83 c0 18             	add    $0x18,%eax
8010149a:	83 ec 04             	sub    $0x4,%esp
8010149d:	68 00 02 00 00       	push   $0x200
801014a2:	6a 00                	push   $0x0
801014a4:	50                   	push   %eax
801014a5:	e8 6d 4a 00 00       	call   80105f17 <memset>
801014aa:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801014ad:	83 ec 0c             	sub    $0xc,%esp
801014b0:	ff 75 f4             	pushl  -0xc(%ebp)
801014b3:	e8 7f 23 00 00       	call   80103837 <log_write>
801014b8:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801014bb:	83 ec 0c             	sub    $0xc,%esp
801014be:	ff 75 f4             	pushl  -0xc(%ebp)
801014c1:	e8 68 ed ff ff       	call   8010022e <brelse>
801014c6:	83 c4 10             	add    $0x10,%esp
}
801014c9:	90                   	nop
801014ca:	c9                   	leave  
801014cb:	c3                   	ret    

801014cc <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014cc:	55                   	push   %ebp
801014cd:	89 e5                	mov    %esp,%ebp
801014cf:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014d2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014e0:	e9 13 01 00 00       	jmp    801015f8 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
801014e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014e8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014ee:	85 c0                	test   %eax,%eax
801014f0:	0f 48 c2             	cmovs  %edx,%eax
801014f3:	c1 f8 0c             	sar    $0xc,%eax
801014f6:	89 c2                	mov    %eax,%edx
801014f8:	a1 58 22 11 80       	mov    0x80112258,%eax
801014fd:	01 d0                	add    %edx,%eax
801014ff:	83 ec 08             	sub    $0x8,%esp
80101502:	50                   	push   %eax
80101503:	ff 75 08             	pushl  0x8(%ebp)
80101506:	e8 ab ec ff ff       	call   801001b6 <bread>
8010150b:	83 c4 10             	add    $0x10,%esp
8010150e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101511:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101518:	e9 a6 00 00 00       	jmp    801015c3 <balloc+0xf7>
      m = 1 << (bi % 8);
8010151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101520:	99                   	cltd   
80101521:	c1 ea 1d             	shr    $0x1d,%edx
80101524:	01 d0                	add    %edx,%eax
80101526:	83 e0 07             	and    $0x7,%eax
80101529:	29 d0                	sub    %edx,%eax
8010152b:	ba 01 00 00 00       	mov    $0x1,%edx
80101530:	89 c1                	mov    %eax,%ecx
80101532:	d3 e2                	shl    %cl,%edx
80101534:	89 d0                	mov    %edx,%eax
80101536:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101539:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153c:	8d 50 07             	lea    0x7(%eax),%edx
8010153f:	85 c0                	test   %eax,%eax
80101541:	0f 48 c2             	cmovs  %edx,%eax
80101544:	c1 f8 03             	sar    $0x3,%eax
80101547:	89 c2                	mov    %eax,%edx
80101549:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010154c:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101551:	0f b6 c0             	movzbl %al,%eax
80101554:	23 45 e8             	and    -0x18(%ebp),%eax
80101557:	85 c0                	test   %eax,%eax
80101559:	75 64                	jne    801015bf <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010155b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010155e:	8d 50 07             	lea    0x7(%eax),%edx
80101561:	85 c0                	test   %eax,%eax
80101563:	0f 48 c2             	cmovs  %edx,%eax
80101566:	c1 f8 03             	sar    $0x3,%eax
80101569:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010156c:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101571:	89 d1                	mov    %edx,%ecx
80101573:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101576:	09 ca                	or     %ecx,%edx
80101578:	89 d1                	mov    %edx,%ecx
8010157a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010157d:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
80101581:	83 ec 0c             	sub    $0xc,%esp
80101584:	ff 75 ec             	pushl  -0x14(%ebp)
80101587:	e8 ab 22 00 00       	call   80103837 <log_write>
8010158c:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010158f:	83 ec 0c             	sub    $0xc,%esp
80101592:	ff 75 ec             	pushl  -0x14(%ebp)
80101595:	e8 94 ec ff ff       	call   8010022e <brelse>
8010159a:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010159d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a3:	01 c2                	add    %eax,%edx
801015a5:	8b 45 08             	mov    0x8(%ebp),%eax
801015a8:	83 ec 08             	sub    $0x8,%esp
801015ab:	52                   	push   %edx
801015ac:	50                   	push   %eax
801015ad:	e8 c6 fe ff ff       	call   80101478 <bzero>
801015b2:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801015b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015bb:	01 d0                	add    %edx,%eax
801015bd:	eb 57                	jmp    80101616 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015bf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015c3:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015ca:	7f 17                	jg     801015e3 <balloc+0x117>
801015cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d2:	01 d0                	add    %edx,%eax
801015d4:	89 c2                	mov    %eax,%edx
801015d6:	a1 40 22 11 80       	mov    0x80112240,%eax
801015db:	39 c2                	cmp    %eax,%edx
801015dd:	0f 82 3a ff ff ff    	jb     8010151d <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015e3:	83 ec 0c             	sub    $0xc,%esp
801015e6:	ff 75 ec             	pushl  -0x14(%ebp)
801015e9:	e8 40 ec ff ff       	call   8010022e <brelse>
801015ee:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015f1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015f8:	8b 15 40 22 11 80    	mov    0x80112240,%edx
801015fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101601:	39 c2                	cmp    %eax,%edx
80101603:	0f 87 dc fe ff ff    	ja     801014e5 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101609:	83 ec 0c             	sub    $0xc,%esp
8010160c:	68 dc 93 10 80       	push   $0x801093dc
80101611:	e8 50 ef ff ff       	call   80100566 <panic>
}
80101616:	c9                   	leave  
80101617:	c3                   	ret    

80101618 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101618:	55                   	push   %ebp
80101619:	89 e5                	mov    %esp,%ebp
8010161b:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010161e:	83 ec 08             	sub    $0x8,%esp
80101621:	68 40 22 11 80       	push   $0x80112240
80101626:	ff 75 08             	pushl  0x8(%ebp)
80101629:	e8 08 fe ff ff       	call   80101436 <readsb>
8010162e:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101631:	8b 45 0c             	mov    0xc(%ebp),%eax
80101634:	c1 e8 0c             	shr    $0xc,%eax
80101637:	89 c2                	mov    %eax,%edx
80101639:	a1 58 22 11 80       	mov    0x80112258,%eax
8010163e:	01 c2                	add    %eax,%edx
80101640:	8b 45 08             	mov    0x8(%ebp),%eax
80101643:	83 ec 08             	sub    $0x8,%esp
80101646:	52                   	push   %edx
80101647:	50                   	push   %eax
80101648:	e8 69 eb ff ff       	call   801001b6 <bread>
8010164d:	83 c4 10             	add    $0x10,%esp
80101650:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101653:	8b 45 0c             	mov    0xc(%ebp),%eax
80101656:	25 ff 0f 00 00       	and    $0xfff,%eax
8010165b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010165e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101661:	99                   	cltd   
80101662:	c1 ea 1d             	shr    $0x1d,%edx
80101665:	01 d0                	add    %edx,%eax
80101667:	83 e0 07             	and    $0x7,%eax
8010166a:	29 d0                	sub    %edx,%eax
8010166c:	ba 01 00 00 00       	mov    $0x1,%edx
80101671:	89 c1                	mov    %eax,%ecx
80101673:	d3 e2                	shl    %cl,%edx
80101675:	89 d0                	mov    %edx,%eax
80101677:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010167d:	8d 50 07             	lea    0x7(%eax),%edx
80101680:	85 c0                	test   %eax,%eax
80101682:	0f 48 c2             	cmovs  %edx,%eax
80101685:	c1 f8 03             	sar    $0x3,%eax
80101688:	89 c2                	mov    %eax,%edx
8010168a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010168d:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101692:	0f b6 c0             	movzbl %al,%eax
80101695:	23 45 ec             	and    -0x14(%ebp),%eax
80101698:	85 c0                	test   %eax,%eax
8010169a:	75 0d                	jne    801016a9 <bfree+0x91>
    panic("freeing free block");
8010169c:	83 ec 0c             	sub    $0xc,%esp
8010169f:	68 f2 93 10 80       	push   $0x801093f2
801016a4:	e8 bd ee ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016ac:	8d 50 07             	lea    0x7(%eax),%edx
801016af:	85 c0                	test   %eax,%eax
801016b1:	0f 48 c2             	cmovs  %edx,%eax
801016b4:	c1 f8 03             	sar    $0x3,%eax
801016b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ba:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016bf:	89 d1                	mov    %edx,%ecx
801016c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016c4:	f7 d2                	not    %edx
801016c6:	21 ca                	and    %ecx,%edx
801016c8:	89 d1                	mov    %edx,%ecx
801016ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016cd:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016d1:	83 ec 0c             	sub    $0xc,%esp
801016d4:	ff 75 f4             	pushl  -0xc(%ebp)
801016d7:	e8 5b 21 00 00       	call   80103837 <log_write>
801016dc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016df:	83 ec 0c             	sub    $0xc,%esp
801016e2:	ff 75 f4             	pushl  -0xc(%ebp)
801016e5:	e8 44 eb ff ff       	call   8010022e <brelse>
801016ea:	83 c4 10             	add    $0x10,%esp
}
801016ed:	90                   	nop
801016ee:	c9                   	leave  
801016ef:	c3                   	ret    

801016f0 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016f0:	55                   	push   %ebp
801016f1:	89 e5                	mov    %esp,%ebp
801016f3:	57                   	push   %edi
801016f4:	56                   	push   %esi
801016f5:	53                   	push   %ebx
801016f6:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801016f9:	83 ec 08             	sub    $0x8,%esp
801016fc:	68 05 94 10 80       	push   $0x80109405
80101701:	68 60 22 11 80       	push   $0x80112260
80101706:	e8 87 45 00 00       	call   80105c92 <initlock>
8010170b:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010170e:	83 ec 08             	sub    $0x8,%esp
80101711:	68 40 22 11 80       	push   $0x80112240
80101716:	ff 75 08             	pushl  0x8(%ebp)
80101719:	e8 18 fd ff ff       	call   80101436 <readsb>
8010171e:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101721:	a1 58 22 11 80       	mov    0x80112258,%eax
80101726:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101729:	8b 3d 54 22 11 80    	mov    0x80112254,%edi
8010172f:	8b 35 50 22 11 80    	mov    0x80112250,%esi
80101735:	8b 1d 4c 22 11 80    	mov    0x8011224c,%ebx
8010173b:	8b 0d 48 22 11 80    	mov    0x80112248,%ecx
80101741:	8b 15 44 22 11 80    	mov    0x80112244,%edx
80101747:	a1 40 22 11 80       	mov    0x80112240,%eax
8010174c:	ff 75 e4             	pushl  -0x1c(%ebp)
8010174f:	57                   	push   %edi
80101750:	56                   	push   %esi
80101751:	53                   	push   %ebx
80101752:	51                   	push   %ecx
80101753:	52                   	push   %edx
80101754:	50                   	push   %eax
80101755:	68 0c 94 10 80       	push   $0x8010940c
8010175a:	e8 67 ec ff ff       	call   801003c6 <cprintf>
8010175f:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101762:	90                   	nop
80101763:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101766:	5b                   	pop    %ebx
80101767:	5e                   	pop    %esi
80101768:	5f                   	pop    %edi
80101769:	5d                   	pop    %ebp
8010176a:	c3                   	ret    

8010176b <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010176b:	55                   	push   %ebp
8010176c:	89 e5                	mov    %esp,%ebp
8010176e:	83 ec 28             	sub    $0x28,%esp
80101771:	8b 45 0c             	mov    0xc(%ebp),%eax
80101774:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101778:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010177f:	e9 9e 00 00 00       	jmp    80101822 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101787:	c1 e8 03             	shr    $0x3,%eax
8010178a:	89 c2                	mov    %eax,%edx
8010178c:	a1 54 22 11 80       	mov    0x80112254,%eax
80101791:	01 d0                	add    %edx,%eax
80101793:	83 ec 08             	sub    $0x8,%esp
80101796:	50                   	push   %eax
80101797:	ff 75 08             	pushl  0x8(%ebp)
8010179a:	e8 17 ea ff ff       	call   801001b6 <bread>
8010179f:	83 c4 10             	add    $0x10,%esp
801017a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a8:	8d 50 18             	lea    0x18(%eax),%edx
801017ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ae:	83 e0 07             	and    $0x7,%eax
801017b1:	c1 e0 06             	shl    $0x6,%eax
801017b4:	01 d0                	add    %edx,%eax
801017b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017bc:	0f b7 00             	movzwl (%eax),%eax
801017bf:	66 85 c0             	test   %ax,%ax
801017c2:	75 4c                	jne    80101810 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801017c4:	83 ec 04             	sub    $0x4,%esp
801017c7:	6a 40                	push   $0x40
801017c9:	6a 00                	push   $0x0
801017cb:	ff 75 ec             	pushl  -0x14(%ebp)
801017ce:	e8 44 47 00 00       	call   80105f17 <memset>
801017d3:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017d9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017dd:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017e0:	83 ec 0c             	sub    $0xc,%esp
801017e3:	ff 75 f0             	pushl  -0x10(%ebp)
801017e6:	e8 4c 20 00 00       	call   80103837 <log_write>
801017eb:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017ee:	83 ec 0c             	sub    $0xc,%esp
801017f1:	ff 75 f0             	pushl  -0x10(%ebp)
801017f4:	e8 35 ea ff ff       	call   8010022e <brelse>
801017f9:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ff:	83 ec 08             	sub    $0x8,%esp
80101802:	50                   	push   %eax
80101803:	ff 75 08             	pushl  0x8(%ebp)
80101806:	e8 f8 00 00 00       	call   80101903 <iget>
8010180b:	83 c4 10             	add    $0x10,%esp
8010180e:	eb 30                	jmp    80101840 <ialloc+0xd5>
    }
    brelse(bp);
80101810:	83 ec 0c             	sub    $0xc,%esp
80101813:	ff 75 f0             	pushl  -0x10(%ebp)
80101816:	e8 13 ea ff ff       	call   8010022e <brelse>
8010181b:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010181e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101822:	8b 15 48 22 11 80    	mov    0x80112248,%edx
80101828:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182b:	39 c2                	cmp    %eax,%edx
8010182d:	0f 87 51 ff ff ff    	ja     80101784 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101833:	83 ec 0c             	sub    $0xc,%esp
80101836:	68 5f 94 10 80       	push   $0x8010945f
8010183b:	e8 26 ed ff ff       	call   80100566 <panic>
}
80101840:	c9                   	leave  
80101841:	c3                   	ret    

80101842 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101842:	55                   	push   %ebp
80101843:	89 e5                	mov    %esp,%ebp
80101845:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 04             	mov    0x4(%eax),%eax
8010184e:	c1 e8 03             	shr    $0x3,%eax
80101851:	89 c2                	mov    %eax,%edx
80101853:	a1 54 22 11 80       	mov    0x80112254,%eax
80101858:	01 c2                	add    %eax,%edx
8010185a:	8b 45 08             	mov    0x8(%ebp),%eax
8010185d:	8b 00                	mov    (%eax),%eax
8010185f:	83 ec 08             	sub    $0x8,%esp
80101862:	52                   	push   %edx
80101863:	50                   	push   %eax
80101864:	e8 4d e9 ff ff       	call   801001b6 <bread>
80101869:	83 c4 10             	add    $0x10,%esp
8010186c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010186f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101872:	8d 50 18             	lea    0x18(%eax),%edx
80101875:	8b 45 08             	mov    0x8(%ebp),%eax
80101878:	8b 40 04             	mov    0x4(%eax),%eax
8010187b:	83 e0 07             	and    $0x7,%eax
8010187e:	c1 e0 06             	shl    $0x6,%eax
80101881:	01 d0                	add    %edx,%eax
80101883:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101886:	8b 45 08             	mov    0x8(%ebp),%eax
80101889:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010188d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101890:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101893:	8b 45 08             	mov    0x8(%ebp),%eax
80101896:	0f b7 50 12          	movzwl 0x12(%eax),%edx
8010189a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010189d:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801018a1:	8b 45 08             	mov    0x8(%ebp),%eax
801018a4:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801018a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ab:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801018af:	8b 45 08             	mov    0x8(%ebp),%eax
801018b2:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b9:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018bd:	8b 45 08             	mov    0x8(%ebp),%eax
801018c0:	8b 50 18             	mov    0x18(%eax),%edx
801018c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018c6:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018c9:	8b 45 08             	mov    0x8(%ebp),%eax
801018cc:	8d 50 1c             	lea    0x1c(%eax),%edx
801018cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d2:	83 c0 0c             	add    $0xc,%eax
801018d5:	83 ec 04             	sub    $0x4,%esp
801018d8:	6a 34                	push   $0x34
801018da:	52                   	push   %edx
801018db:	50                   	push   %eax
801018dc:	e8 f5 46 00 00       	call   80105fd6 <memmove>
801018e1:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018e4:	83 ec 0c             	sub    $0xc,%esp
801018e7:	ff 75 f4             	pushl  -0xc(%ebp)
801018ea:	e8 48 1f 00 00       	call   80103837 <log_write>
801018ef:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018f2:	83 ec 0c             	sub    $0xc,%esp
801018f5:	ff 75 f4             	pushl  -0xc(%ebp)
801018f8:	e8 31 e9 ff ff       	call   8010022e <brelse>
801018fd:	83 c4 10             	add    $0x10,%esp
}
80101900:	90                   	nop
80101901:	c9                   	leave  
80101902:	c3                   	ret    

80101903 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101903:	55                   	push   %ebp
80101904:	89 e5                	mov    %esp,%ebp
80101906:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101909:	83 ec 0c             	sub    $0xc,%esp
8010190c:	68 60 22 11 80       	push   $0x80112260
80101911:	e8 9e 43 00 00       	call   80105cb4 <acquire>
80101916:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101919:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101920:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101927:	eb 5d                	jmp    80101986 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101929:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192c:	8b 40 08             	mov    0x8(%eax),%eax
8010192f:	85 c0                	test   %eax,%eax
80101931:	7e 39                	jle    8010196c <iget+0x69>
80101933:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101936:	8b 00                	mov    (%eax),%eax
80101938:	3b 45 08             	cmp    0x8(%ebp),%eax
8010193b:	75 2f                	jne    8010196c <iget+0x69>
8010193d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101940:	8b 40 04             	mov    0x4(%eax),%eax
80101943:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101946:	75 24                	jne    8010196c <iget+0x69>
      ip->ref++;
80101948:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194b:	8b 40 08             	mov    0x8(%eax),%eax
8010194e:	8d 50 01             	lea    0x1(%eax),%edx
80101951:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101954:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101957:	83 ec 0c             	sub    $0xc,%esp
8010195a:	68 60 22 11 80       	push   $0x80112260
8010195f:	e8 b7 43 00 00       	call   80105d1b <release>
80101964:	83 c4 10             	add    $0x10,%esp
      return ip;
80101967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196a:	eb 74                	jmp    801019e0 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010196c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101970:	75 10                	jne    80101982 <iget+0x7f>
80101972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101975:	8b 40 08             	mov    0x8(%eax),%eax
80101978:	85 c0                	test   %eax,%eax
8010197a:	75 06                	jne    80101982 <iget+0x7f>
      empty = ip;
8010197c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101982:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101986:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
8010198d:	72 9a                	jb     80101929 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010198f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101993:	75 0d                	jne    801019a2 <iget+0x9f>
    panic("iget: no inodes");
80101995:	83 ec 0c             	sub    $0xc,%esp
80101998:	68 71 94 10 80       	push   $0x80109471
8010199d:	e8 c4 eb ff ff       	call   80100566 <panic>

  ip = empty;
801019a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ab:	8b 55 08             	mov    0x8(%ebp),%edx
801019ae:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801019b6:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019cd:	83 ec 0c             	sub    $0xc,%esp
801019d0:	68 60 22 11 80       	push   $0x80112260
801019d5:	e8 41 43 00 00       	call   80105d1b <release>
801019da:	83 c4 10             	add    $0x10,%esp

  return ip;
801019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019e0:	c9                   	leave  
801019e1:	c3                   	ret    

801019e2 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019e2:	55                   	push   %ebp
801019e3:	89 e5                	mov    %esp,%ebp
801019e5:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019e8:	83 ec 0c             	sub    $0xc,%esp
801019eb:	68 60 22 11 80       	push   $0x80112260
801019f0:	e8 bf 42 00 00       	call   80105cb4 <acquire>
801019f5:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019f8:	8b 45 08             	mov    0x8(%ebp),%eax
801019fb:	8b 40 08             	mov    0x8(%eax),%eax
801019fe:	8d 50 01             	lea    0x1(%eax),%edx
80101a01:	8b 45 08             	mov    0x8(%ebp),%eax
80101a04:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a07:	83 ec 0c             	sub    $0xc,%esp
80101a0a:	68 60 22 11 80       	push   $0x80112260
80101a0f:	e8 07 43 00 00       	call   80105d1b <release>
80101a14:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a17:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a1a:	c9                   	leave  
80101a1b:	c3                   	ret    

80101a1c <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a1c:	55                   	push   %ebp
80101a1d:	89 e5                	mov    %esp,%ebp
80101a1f:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a22:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a26:	74 0a                	je     80101a32 <ilock+0x16>
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	8b 40 08             	mov    0x8(%eax),%eax
80101a2e:	85 c0                	test   %eax,%eax
80101a30:	7f 0d                	jg     80101a3f <ilock+0x23>
    panic("ilock");
80101a32:	83 ec 0c             	sub    $0xc,%esp
80101a35:	68 81 94 10 80       	push   $0x80109481
80101a3a:	e8 27 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a3f:	83 ec 0c             	sub    $0xc,%esp
80101a42:	68 60 22 11 80       	push   $0x80112260
80101a47:	e8 68 42 00 00       	call   80105cb4 <acquire>
80101a4c:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a4f:	eb 13                	jmp    80101a64 <ilock+0x48>
    sleep(ip, &icache.lock);
80101a51:	83 ec 08             	sub    $0x8,%esp
80101a54:	68 60 22 11 80       	push   $0x80112260
80101a59:	ff 75 08             	pushl  0x8(%ebp)
80101a5c:	e8 a8 34 00 00       	call   80104f09 <sleep>
80101a61:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101a64:	8b 45 08             	mov    0x8(%ebp),%eax
80101a67:	8b 40 0c             	mov    0xc(%eax),%eax
80101a6a:	83 e0 01             	and    $0x1,%eax
80101a6d:	85 c0                	test   %eax,%eax
80101a6f:	75 e0                	jne    80101a51 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101a71:	8b 45 08             	mov    0x8(%ebp),%eax
80101a74:	8b 40 0c             	mov    0xc(%eax),%eax
80101a77:	83 c8 01             	or     $0x1,%eax
80101a7a:	89 c2                	mov    %eax,%edx
80101a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7f:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a82:	83 ec 0c             	sub    $0xc,%esp
80101a85:	68 60 22 11 80       	push   $0x80112260
80101a8a:	e8 8c 42 00 00       	call   80105d1b <release>
80101a8f:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a92:	8b 45 08             	mov    0x8(%ebp),%eax
80101a95:	8b 40 0c             	mov    0xc(%eax),%eax
80101a98:	83 e0 02             	and    $0x2,%eax
80101a9b:	85 c0                	test   %eax,%eax
80101a9d:	0f 85 d4 00 00 00    	jne    80101b77 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	8b 40 04             	mov    0x4(%eax),%eax
80101aa9:	c1 e8 03             	shr    $0x3,%eax
80101aac:	89 c2                	mov    %eax,%edx
80101aae:	a1 54 22 11 80       	mov    0x80112254,%eax
80101ab3:	01 c2                	add    %eax,%edx
80101ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab8:	8b 00                	mov    (%eax),%eax
80101aba:	83 ec 08             	sub    $0x8,%esp
80101abd:	52                   	push   %edx
80101abe:	50                   	push   %eax
80101abf:	e8 f2 e6 ff ff       	call   801001b6 <bread>
80101ac4:	83 c4 10             	add    $0x10,%esp
80101ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101acd:	8d 50 18             	lea    0x18(%eax),%edx
80101ad0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad3:	8b 40 04             	mov    0x4(%eax),%eax
80101ad6:	83 e0 07             	and    $0x7,%eax
80101ad9:	c1 e0 06             	shl    $0x6,%eax
80101adc:	01 d0                	add    %edx,%eax
80101ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ae1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae4:	0f b7 10             	movzwl (%eax),%edx
80101ae7:	8b 45 08             	mov    0x8(%ebp),%eax
80101aea:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af1:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101af5:	8b 45 08             	mov    0x8(%ebp),%eax
80101af8:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aff:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101b03:	8b 45 08             	mov    0x8(%ebp),%eax
80101b06:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b0d:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1b:	8b 50 08             	mov    0x8(%eax),%edx
80101b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b21:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b27:	8d 50 0c             	lea    0xc(%eax),%edx
80101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2d:	83 c0 1c             	add    $0x1c,%eax
80101b30:	83 ec 04             	sub    $0x4,%esp
80101b33:	6a 34                	push   $0x34
80101b35:	52                   	push   %edx
80101b36:	50                   	push   %eax
80101b37:	e8 9a 44 00 00       	call   80105fd6 <memmove>
80101b3c:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b3f:	83 ec 0c             	sub    $0xc,%esp
80101b42:	ff 75 f4             	pushl  -0xc(%ebp)
80101b45:	e8 e4 e6 ff ff       	call   8010022e <brelse>
80101b4a:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b50:	8b 40 0c             	mov    0xc(%eax),%eax
80101b53:	83 c8 02             	or     $0x2,%eax
80101b56:	89 c2                	mov    %eax,%edx
80101b58:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5b:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b61:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b65:	66 85 c0             	test   %ax,%ax
80101b68:	75 0d                	jne    80101b77 <ilock+0x15b>
      panic("ilock: no type");
80101b6a:	83 ec 0c             	sub    $0xc,%esp
80101b6d:	68 87 94 10 80       	push   $0x80109487
80101b72:	e8 ef e9 ff ff       	call   80100566 <panic>
  }
}
80101b77:	90                   	nop
80101b78:	c9                   	leave  
80101b79:	c3                   	ret    

80101b7a <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b7a:	55                   	push   %ebp
80101b7b:	89 e5                	mov    %esp,%ebp
80101b7d:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101b80:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b84:	74 17                	je     80101b9d <iunlock+0x23>
80101b86:	8b 45 08             	mov    0x8(%ebp),%eax
80101b89:	8b 40 0c             	mov    0xc(%eax),%eax
80101b8c:	83 e0 01             	and    $0x1,%eax
80101b8f:	85 c0                	test   %eax,%eax
80101b91:	74 0a                	je     80101b9d <iunlock+0x23>
80101b93:	8b 45 08             	mov    0x8(%ebp),%eax
80101b96:	8b 40 08             	mov    0x8(%eax),%eax
80101b99:	85 c0                	test   %eax,%eax
80101b9b:	7f 0d                	jg     80101baa <iunlock+0x30>
    panic("iunlock");
80101b9d:	83 ec 0c             	sub    $0xc,%esp
80101ba0:	68 96 94 10 80       	push   $0x80109496
80101ba5:	e8 bc e9 ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101baa:	83 ec 0c             	sub    $0xc,%esp
80101bad:	68 60 22 11 80       	push   $0x80112260
80101bb2:	e8 fd 40 00 00       	call   80105cb4 <acquire>
80101bb7:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101bba:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbd:	8b 40 0c             	mov    0xc(%eax),%eax
80101bc0:	83 e0 fe             	and    $0xfffffffe,%eax
80101bc3:	89 c2                	mov    %eax,%edx
80101bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc8:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101bcb:	83 ec 0c             	sub    $0xc,%esp
80101bce:	ff 75 08             	pushl  0x8(%ebp)
80101bd1:	e8 48 34 00 00       	call   8010501e <wakeup>
80101bd6:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bd9:	83 ec 0c             	sub    $0xc,%esp
80101bdc:	68 60 22 11 80       	push   $0x80112260
80101be1:	e8 35 41 00 00       	call   80105d1b <release>
80101be6:	83 c4 10             	add    $0x10,%esp
}
80101be9:	90                   	nop
80101bea:	c9                   	leave  
80101beb:	c3                   	ret    

80101bec <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bec:	55                   	push   %ebp
80101bed:	89 e5                	mov    %esp,%ebp
80101bef:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101bf2:	83 ec 0c             	sub    $0xc,%esp
80101bf5:	68 60 22 11 80       	push   $0x80112260
80101bfa:	e8 b5 40 00 00       	call   80105cb4 <acquire>
80101bff:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101c02:	8b 45 08             	mov    0x8(%ebp),%eax
80101c05:	8b 40 08             	mov    0x8(%eax),%eax
80101c08:	83 f8 01             	cmp    $0x1,%eax
80101c0b:	0f 85 a9 00 00 00    	jne    80101cba <iput+0xce>
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	8b 40 0c             	mov    0xc(%eax),%eax
80101c17:	83 e0 02             	and    $0x2,%eax
80101c1a:	85 c0                	test   %eax,%eax
80101c1c:	0f 84 98 00 00 00    	je     80101cba <iput+0xce>
80101c22:	8b 45 08             	mov    0x8(%ebp),%eax
80101c25:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c29:	66 85 c0             	test   %ax,%ax
80101c2c:	0f 85 88 00 00 00    	jne    80101cba <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c32:	8b 45 08             	mov    0x8(%ebp),%eax
80101c35:	8b 40 0c             	mov    0xc(%eax),%eax
80101c38:	83 e0 01             	and    $0x1,%eax
80101c3b:	85 c0                	test   %eax,%eax
80101c3d:	74 0d                	je     80101c4c <iput+0x60>
      panic("iput busy");
80101c3f:	83 ec 0c             	sub    $0xc,%esp
80101c42:	68 9e 94 10 80       	push   $0x8010949e
80101c47:	e8 1a e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4f:	8b 40 0c             	mov    0xc(%eax),%eax
80101c52:	83 c8 01             	or     $0x1,%eax
80101c55:	89 c2                	mov    %eax,%edx
80101c57:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5a:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	68 60 22 11 80       	push   $0x80112260
80101c65:	e8 b1 40 00 00       	call   80105d1b <release>
80101c6a:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101c6d:	83 ec 0c             	sub    $0xc,%esp
80101c70:	ff 75 08             	pushl  0x8(%ebp)
80101c73:	e8 a8 01 00 00       	call   80101e20 <itrunc>
80101c78:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101c84:	83 ec 0c             	sub    $0xc,%esp
80101c87:	ff 75 08             	pushl  0x8(%ebp)
80101c8a:	e8 b3 fb ff ff       	call   80101842 <iupdate>
80101c8f:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c92:	83 ec 0c             	sub    $0xc,%esp
80101c95:	68 60 22 11 80       	push   $0x80112260
80101c9a:	e8 15 40 00 00       	call   80105cb4 <acquire>
80101c9f:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101cac:	83 ec 0c             	sub    $0xc,%esp
80101caf:	ff 75 08             	pushl  0x8(%ebp)
80101cb2:	e8 67 33 00 00       	call   8010501e <wakeup>
80101cb7:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101cba:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbd:	8b 40 08             	mov    0x8(%eax),%eax
80101cc0:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cc3:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc6:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cc9:	83 ec 0c             	sub    $0xc,%esp
80101ccc:	68 60 22 11 80       	push   $0x80112260
80101cd1:	e8 45 40 00 00       	call   80105d1b <release>
80101cd6:	83 c4 10             	add    $0x10,%esp
}
80101cd9:	90                   	nop
80101cda:	c9                   	leave  
80101cdb:	c3                   	ret    

80101cdc <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cdc:	55                   	push   %ebp
80101cdd:	89 e5                	mov    %esp,%ebp
80101cdf:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101ce2:	83 ec 0c             	sub    $0xc,%esp
80101ce5:	ff 75 08             	pushl  0x8(%ebp)
80101ce8:	e8 8d fe ff ff       	call   80101b7a <iunlock>
80101ced:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cf0:	83 ec 0c             	sub    $0xc,%esp
80101cf3:	ff 75 08             	pushl  0x8(%ebp)
80101cf6:	e8 f1 fe ff ff       	call   80101bec <iput>
80101cfb:	83 c4 10             	add    $0x10,%esp
}
80101cfe:	90                   	nop
80101cff:	c9                   	leave  
80101d00:	c3                   	ret    

80101d01 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d01:	55                   	push   %ebp
80101d02:	89 e5                	mov    %esp,%ebp
80101d04:	53                   	push   %ebx
80101d05:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d08:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d0c:	77 42                	ja     80101d50 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d11:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d14:	83 c2 04             	add    $0x4,%edx
80101d17:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d22:	75 24                	jne    80101d48 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d24:	8b 45 08             	mov    0x8(%ebp),%eax
80101d27:	8b 00                	mov    (%eax),%eax
80101d29:	83 ec 0c             	sub    $0xc,%esp
80101d2c:	50                   	push   %eax
80101d2d:	e8 9a f7 ff ff       	call   801014cc <balloc>
80101d32:	83 c4 10             	add    $0x10,%esp
80101d35:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d38:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d3e:	8d 4a 04             	lea    0x4(%edx),%ecx
80101d41:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d44:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d4b:	e9 cb 00 00 00       	jmp    80101e1b <bmap+0x11a>
  }
  bn -= NDIRECT;
80101d50:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d54:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d58:	0f 87 b0 00 00 00    	ja     80101e0e <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d61:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d6b:	75 1d                	jne    80101d8a <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d70:	8b 00                	mov    (%eax),%eax
80101d72:	83 ec 0c             	sub    $0xc,%esp
80101d75:	50                   	push   %eax
80101d76:	e8 51 f7 ff ff       	call   801014cc <balloc>
80101d7b:	83 c4 10             	add    $0x10,%esp
80101d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d81:	8b 45 08             	mov    0x8(%ebp),%eax
80101d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d87:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8d:	8b 00                	mov    (%eax),%eax
80101d8f:	83 ec 08             	sub    $0x8,%esp
80101d92:	ff 75 f4             	pushl  -0xc(%ebp)
80101d95:	50                   	push   %eax
80101d96:	e8 1b e4 ff ff       	call   801001b6 <bread>
80101d9b:	83 c4 10             	add    $0x10,%esp
80101d9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da4:	83 c0 18             	add    $0x18,%eax
80101da7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101daa:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dad:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101db4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101db7:	01 d0                	add    %edx,%eax
80101db9:	8b 00                	mov    (%eax),%eax
80101dbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dc2:	75 37                	jne    80101dfb <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dc7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dce:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dd1:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101dd4:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd7:	8b 00                	mov    (%eax),%eax
80101dd9:	83 ec 0c             	sub    $0xc,%esp
80101ddc:	50                   	push   %eax
80101ddd:	e8 ea f6 ff ff       	call   801014cc <balloc>
80101de2:	83 c4 10             	add    $0x10,%esp
80101de5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101deb:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101ded:	83 ec 0c             	sub    $0xc,%esp
80101df0:	ff 75 f0             	pushl  -0x10(%ebp)
80101df3:	e8 3f 1a 00 00       	call   80103837 <log_write>
80101df8:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101dfb:	83 ec 0c             	sub    $0xc,%esp
80101dfe:	ff 75 f0             	pushl  -0x10(%ebp)
80101e01:	e8 28 e4 ff ff       	call   8010022e <brelse>
80101e06:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e0c:	eb 0d                	jmp    80101e1b <bmap+0x11a>
  }

  panic("bmap: out of range");
80101e0e:	83 ec 0c             	sub    $0xc,%esp
80101e11:	68 a8 94 10 80       	push   $0x801094a8
80101e16:	e8 4b e7 ff ff       	call   80100566 <panic>
}
80101e1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101e1e:	c9                   	leave  
80101e1f:	c3                   	ret    

80101e20 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e20:	55                   	push   %ebp
80101e21:	89 e5                	mov    %esp,%ebp
80101e23:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e2d:	eb 45                	jmp    80101e74 <itrunc+0x54>
    if(ip->addrs[i]){
80101e2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e35:	83 c2 04             	add    $0x4,%edx
80101e38:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e3c:	85 c0                	test   %eax,%eax
80101e3e:	74 30                	je     80101e70 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101e40:	8b 45 08             	mov    0x8(%ebp),%eax
80101e43:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e46:	83 c2 04             	add    $0x4,%edx
80101e49:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e4d:	8b 55 08             	mov    0x8(%ebp),%edx
80101e50:	8b 12                	mov    (%edx),%edx
80101e52:	83 ec 08             	sub    $0x8,%esp
80101e55:	50                   	push   %eax
80101e56:	52                   	push   %edx
80101e57:	e8 bc f7 ff ff       	call   80101618 <bfree>
80101e5c:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e65:	83 c2 04             	add    $0x4,%edx
80101e68:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e6f:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e70:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e74:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e78:	7e b5                	jle    80101e2f <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e80:	85 c0                	test   %eax,%eax
80101e82:	0f 84 a1 00 00 00    	je     80101f29 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e88:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8b:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101e91:	8b 00                	mov    (%eax),%eax
80101e93:	83 ec 08             	sub    $0x8,%esp
80101e96:	52                   	push   %edx
80101e97:	50                   	push   %eax
80101e98:	e8 19 e3 ff ff       	call   801001b6 <bread>
80101e9d:	83 c4 10             	add    $0x10,%esp
80101ea0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ea3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ea6:	83 c0 18             	add    $0x18,%eax
80101ea9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101eac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eb3:	eb 3c                	jmp    80101ef1 <itrunc+0xd1>
      if(a[j])
80101eb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101eb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ebf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ec2:	01 d0                	add    %edx,%eax
80101ec4:	8b 00                	mov    (%eax),%eax
80101ec6:	85 c0                	test   %eax,%eax
80101ec8:	74 23                	je     80101eed <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101eca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ecd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ed4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101ed7:	01 d0                	add    %edx,%eax
80101ed9:	8b 00                	mov    (%eax),%eax
80101edb:	8b 55 08             	mov    0x8(%ebp),%edx
80101ede:	8b 12                	mov    (%edx),%edx
80101ee0:	83 ec 08             	sub    $0x8,%esp
80101ee3:	50                   	push   %eax
80101ee4:	52                   	push   %edx
80101ee5:	e8 2e f7 ff ff       	call   80101618 <bfree>
80101eea:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101eed:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ef1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef4:	83 f8 7f             	cmp    $0x7f,%eax
80101ef7:	76 bc                	jbe    80101eb5 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ef9:	83 ec 0c             	sub    $0xc,%esp
80101efc:	ff 75 ec             	pushl  -0x14(%ebp)
80101eff:	e8 2a e3 ff ff       	call   8010022e <brelse>
80101f04:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f07:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f0d:	8b 55 08             	mov    0x8(%ebp),%edx
80101f10:	8b 12                	mov    (%edx),%edx
80101f12:	83 ec 08             	sub    $0x8,%esp
80101f15:	50                   	push   %eax
80101f16:	52                   	push   %edx
80101f17:	e8 fc f6 ff ff       	call   80101618 <bfree>
80101f1c:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f22:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f29:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2c:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101f33:	83 ec 0c             	sub    $0xc,%esp
80101f36:	ff 75 08             	pushl  0x8(%ebp)
80101f39:	e8 04 f9 ff ff       	call   80101842 <iupdate>
80101f3e:	83 c4 10             	add    $0x10,%esp
}
80101f41:	90                   	nop
80101f42:	c9                   	leave  
80101f43:	c3                   	ret    

80101f44 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f44:	55                   	push   %ebp
80101f45:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	8b 00                	mov    (%eax),%eax
80101f4c:	89 c2                	mov    %eax,%edx
80101f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f51:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f54:	8b 45 08             	mov    0x8(%ebp),%eax
80101f57:	8b 50 04             	mov    0x4(%eax),%edx
80101f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5d:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f67:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f6a:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f70:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f74:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f77:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	8b 50 18             	mov    0x18(%eax),%edx
80101f81:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f84:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f87:	90                   	nop
80101f88:	5d                   	pop    %ebp
80101f89:	c3                   	ret    

80101f8a <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f8a:	55                   	push   %ebp
80101f8b:	89 e5                	mov    %esp,%ebp
80101f8d:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f90:	8b 45 08             	mov    0x8(%ebp),%eax
80101f93:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101f97:	66 83 f8 03          	cmp    $0x3,%ax
80101f9b:	75 5c                	jne    80101ff9 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fa4:	66 85 c0             	test   %ax,%ax
80101fa7:	78 20                	js     80101fc9 <readi+0x3f>
80101fa9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fac:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fb0:	66 83 f8 09          	cmp    $0x9,%ax
80101fb4:	7f 13                	jg     80101fc9 <readi+0x3f>
80101fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fbd:	98                   	cwtl   
80101fbe:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fc5:	85 c0                	test   %eax,%eax
80101fc7:	75 0a                	jne    80101fd3 <readi+0x49>
      return -1;
80101fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fce:	e9 0c 01 00 00       	jmp    801020df <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101fd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fda:	98                   	cwtl   
80101fdb:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101fe2:	8b 55 14             	mov    0x14(%ebp),%edx
80101fe5:	83 ec 04             	sub    $0x4,%esp
80101fe8:	52                   	push   %edx
80101fe9:	ff 75 0c             	pushl  0xc(%ebp)
80101fec:	ff 75 08             	pushl  0x8(%ebp)
80101fef:	ff d0                	call   *%eax
80101ff1:	83 c4 10             	add    $0x10,%esp
80101ff4:	e9 e6 00 00 00       	jmp    801020df <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ffc:	8b 40 18             	mov    0x18(%eax),%eax
80101fff:	3b 45 10             	cmp    0x10(%ebp),%eax
80102002:	72 0d                	jb     80102011 <readi+0x87>
80102004:	8b 55 10             	mov    0x10(%ebp),%edx
80102007:	8b 45 14             	mov    0x14(%ebp),%eax
8010200a:	01 d0                	add    %edx,%eax
8010200c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010200f:	73 0a                	jae    8010201b <readi+0x91>
    return -1;
80102011:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102016:	e9 c4 00 00 00       	jmp    801020df <readi+0x155>
  if(off + n > ip->size)
8010201b:	8b 55 10             	mov    0x10(%ebp),%edx
8010201e:	8b 45 14             	mov    0x14(%ebp),%eax
80102021:	01 c2                	add    %eax,%edx
80102023:	8b 45 08             	mov    0x8(%ebp),%eax
80102026:	8b 40 18             	mov    0x18(%eax),%eax
80102029:	39 c2                	cmp    %eax,%edx
8010202b:	76 0c                	jbe    80102039 <readi+0xaf>
    n = ip->size - off;
8010202d:	8b 45 08             	mov    0x8(%ebp),%eax
80102030:	8b 40 18             	mov    0x18(%eax),%eax
80102033:	2b 45 10             	sub    0x10(%ebp),%eax
80102036:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102039:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102040:	e9 8b 00 00 00       	jmp    801020d0 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102045:	8b 45 10             	mov    0x10(%ebp),%eax
80102048:	c1 e8 09             	shr    $0x9,%eax
8010204b:	83 ec 08             	sub    $0x8,%esp
8010204e:	50                   	push   %eax
8010204f:	ff 75 08             	pushl  0x8(%ebp)
80102052:	e8 aa fc ff ff       	call   80101d01 <bmap>
80102057:	83 c4 10             	add    $0x10,%esp
8010205a:	89 c2                	mov    %eax,%edx
8010205c:	8b 45 08             	mov    0x8(%ebp),%eax
8010205f:	8b 00                	mov    (%eax),%eax
80102061:	83 ec 08             	sub    $0x8,%esp
80102064:	52                   	push   %edx
80102065:	50                   	push   %eax
80102066:	e8 4b e1 ff ff       	call   801001b6 <bread>
8010206b:	83 c4 10             	add    $0x10,%esp
8010206e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102071:	8b 45 10             	mov    0x10(%ebp),%eax
80102074:	25 ff 01 00 00       	and    $0x1ff,%eax
80102079:	ba 00 02 00 00       	mov    $0x200,%edx
8010207e:	29 c2                	sub    %eax,%edx
80102080:	8b 45 14             	mov    0x14(%ebp),%eax
80102083:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102086:	39 c2                	cmp    %eax,%edx
80102088:	0f 46 c2             	cmovbe %edx,%eax
8010208b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010208e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102091:	8d 50 18             	lea    0x18(%eax),%edx
80102094:	8b 45 10             	mov    0x10(%ebp),%eax
80102097:	25 ff 01 00 00       	and    $0x1ff,%eax
8010209c:	01 d0                	add    %edx,%eax
8010209e:	83 ec 04             	sub    $0x4,%esp
801020a1:	ff 75 ec             	pushl  -0x14(%ebp)
801020a4:	50                   	push   %eax
801020a5:	ff 75 0c             	pushl  0xc(%ebp)
801020a8:	e8 29 3f 00 00       	call   80105fd6 <memmove>
801020ad:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020b0:	83 ec 0c             	sub    $0xc,%esp
801020b3:	ff 75 f0             	pushl  -0x10(%ebp)
801020b6:	e8 73 e1 ff ff       	call   8010022e <brelse>
801020bb:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c1:	01 45 f4             	add    %eax,-0xc(%ebp)
801020c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020c7:	01 45 10             	add    %eax,0x10(%ebp)
801020ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020cd:	01 45 0c             	add    %eax,0xc(%ebp)
801020d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020d3:	3b 45 14             	cmp    0x14(%ebp),%eax
801020d6:	0f 82 69 ff ff ff    	jb     80102045 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020dc:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020df:	c9                   	leave  
801020e0:	c3                   	ret    

801020e1 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020e1:	55                   	push   %ebp
801020e2:	89 e5                	mov    %esp,%ebp
801020e4:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020e7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ea:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801020ee:	66 83 f8 03          	cmp    $0x3,%ax
801020f2:	75 5c                	jne    80102150 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020f4:	8b 45 08             	mov    0x8(%ebp),%eax
801020f7:	0f b7 40 12          	movzwl 0x12(%eax),%eax
801020fb:	66 85 c0             	test   %ax,%ax
801020fe:	78 20                	js     80102120 <writei+0x3f>
80102100:	8b 45 08             	mov    0x8(%ebp),%eax
80102103:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102107:	66 83 f8 09          	cmp    $0x9,%ax
8010210b:	7f 13                	jg     80102120 <writei+0x3f>
8010210d:	8b 45 08             	mov    0x8(%ebp),%eax
80102110:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102114:	98                   	cwtl   
80102115:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
8010211c:	85 c0                	test   %eax,%eax
8010211e:	75 0a                	jne    8010212a <writei+0x49>
      return -1;
80102120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102125:	e9 3d 01 00 00       	jmp    80102267 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010212a:	8b 45 08             	mov    0x8(%ebp),%eax
8010212d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102131:	98                   	cwtl   
80102132:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102139:	8b 55 14             	mov    0x14(%ebp),%edx
8010213c:	83 ec 04             	sub    $0x4,%esp
8010213f:	52                   	push   %edx
80102140:	ff 75 0c             	pushl  0xc(%ebp)
80102143:	ff 75 08             	pushl  0x8(%ebp)
80102146:	ff d0                	call   *%eax
80102148:	83 c4 10             	add    $0x10,%esp
8010214b:	e9 17 01 00 00       	jmp    80102267 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102150:	8b 45 08             	mov    0x8(%ebp),%eax
80102153:	8b 40 18             	mov    0x18(%eax),%eax
80102156:	3b 45 10             	cmp    0x10(%ebp),%eax
80102159:	72 0d                	jb     80102168 <writei+0x87>
8010215b:	8b 55 10             	mov    0x10(%ebp),%edx
8010215e:	8b 45 14             	mov    0x14(%ebp),%eax
80102161:	01 d0                	add    %edx,%eax
80102163:	3b 45 10             	cmp    0x10(%ebp),%eax
80102166:	73 0a                	jae    80102172 <writei+0x91>
    return -1;
80102168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216d:	e9 f5 00 00 00       	jmp    80102267 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
80102172:	8b 55 10             	mov    0x10(%ebp),%edx
80102175:	8b 45 14             	mov    0x14(%ebp),%eax
80102178:	01 d0                	add    %edx,%eax
8010217a:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217f:	76 0a                	jbe    8010218b <writei+0xaa>
    return -1;
80102181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102186:	e9 dc 00 00 00       	jmp    80102267 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010218b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102192:	e9 99 00 00 00       	jmp    80102230 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102197:	8b 45 10             	mov    0x10(%ebp),%eax
8010219a:	c1 e8 09             	shr    $0x9,%eax
8010219d:	83 ec 08             	sub    $0x8,%esp
801021a0:	50                   	push   %eax
801021a1:	ff 75 08             	pushl  0x8(%ebp)
801021a4:	e8 58 fb ff ff       	call   80101d01 <bmap>
801021a9:	83 c4 10             	add    $0x10,%esp
801021ac:	89 c2                	mov    %eax,%edx
801021ae:	8b 45 08             	mov    0x8(%ebp),%eax
801021b1:	8b 00                	mov    (%eax),%eax
801021b3:	83 ec 08             	sub    $0x8,%esp
801021b6:	52                   	push   %edx
801021b7:	50                   	push   %eax
801021b8:	e8 f9 df ff ff       	call   801001b6 <bread>
801021bd:	83 c4 10             	add    $0x10,%esp
801021c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021c3:	8b 45 10             	mov    0x10(%ebp),%eax
801021c6:	25 ff 01 00 00       	and    $0x1ff,%eax
801021cb:	ba 00 02 00 00       	mov    $0x200,%edx
801021d0:	29 c2                	sub    %eax,%edx
801021d2:	8b 45 14             	mov    0x14(%ebp),%eax
801021d5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021d8:	39 c2                	cmp    %eax,%edx
801021da:	0f 46 c2             	cmovbe %edx,%eax
801021dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021e3:	8d 50 18             	lea    0x18(%eax),%edx
801021e6:	8b 45 10             	mov    0x10(%ebp),%eax
801021e9:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ee:	01 d0                	add    %edx,%eax
801021f0:	83 ec 04             	sub    $0x4,%esp
801021f3:	ff 75 ec             	pushl  -0x14(%ebp)
801021f6:	ff 75 0c             	pushl  0xc(%ebp)
801021f9:	50                   	push   %eax
801021fa:	e8 d7 3d 00 00       	call   80105fd6 <memmove>
801021ff:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102202:	83 ec 0c             	sub    $0xc,%esp
80102205:	ff 75 f0             	pushl  -0x10(%ebp)
80102208:	e8 2a 16 00 00       	call   80103837 <log_write>
8010220d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102210:	83 ec 0c             	sub    $0xc,%esp
80102213:	ff 75 f0             	pushl  -0x10(%ebp)
80102216:	e8 13 e0 ff ff       	call   8010022e <brelse>
8010221b:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010221e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102221:	01 45 f4             	add    %eax,-0xc(%ebp)
80102224:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102227:	01 45 10             	add    %eax,0x10(%ebp)
8010222a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010222d:	01 45 0c             	add    %eax,0xc(%ebp)
80102230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102233:	3b 45 14             	cmp    0x14(%ebp),%eax
80102236:	0f 82 5b ff ff ff    	jb     80102197 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010223c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102240:	74 22                	je     80102264 <writei+0x183>
80102242:	8b 45 08             	mov    0x8(%ebp),%eax
80102245:	8b 40 18             	mov    0x18(%eax),%eax
80102248:	3b 45 10             	cmp    0x10(%ebp),%eax
8010224b:	73 17                	jae    80102264 <writei+0x183>
    ip->size = off;
8010224d:	8b 45 08             	mov    0x8(%ebp),%eax
80102250:	8b 55 10             	mov    0x10(%ebp),%edx
80102253:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102256:	83 ec 0c             	sub    $0xc,%esp
80102259:	ff 75 08             	pushl  0x8(%ebp)
8010225c:	e8 e1 f5 ff ff       	call   80101842 <iupdate>
80102261:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102264:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102267:	c9                   	leave  
80102268:	c3                   	ret    

80102269 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102269:	55                   	push   %ebp
8010226a:	89 e5                	mov    %esp,%ebp
8010226c:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
8010226f:	83 ec 04             	sub    $0x4,%esp
80102272:	6a 0e                	push   $0xe
80102274:	ff 75 0c             	pushl  0xc(%ebp)
80102277:	ff 75 08             	pushl  0x8(%ebp)
8010227a:	e8 ed 3d 00 00       	call   8010606c <strncmp>
8010227f:	83 c4 10             	add    $0x10,%esp
}
80102282:	c9                   	leave  
80102283:	c3                   	ret    

80102284 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102284:	55                   	push   %ebp
80102285:	89 e5                	mov    %esp,%ebp
80102287:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010228a:	8b 45 08             	mov    0x8(%ebp),%eax
8010228d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102291:	66 83 f8 01          	cmp    $0x1,%ax
80102295:	74 0d                	je     801022a4 <dirlookup+0x20>
    panic("dirlookup not DIR");
80102297:	83 ec 0c             	sub    $0xc,%esp
8010229a:	68 bb 94 10 80       	push   $0x801094bb
8010229f:	e8 c2 e2 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022ab:	eb 7b                	jmp    80102328 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022ad:	6a 10                	push   $0x10
801022af:	ff 75 f4             	pushl  -0xc(%ebp)
801022b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022b5:	50                   	push   %eax
801022b6:	ff 75 08             	pushl  0x8(%ebp)
801022b9:	e8 cc fc ff ff       	call   80101f8a <readi>
801022be:	83 c4 10             	add    $0x10,%esp
801022c1:	83 f8 10             	cmp    $0x10,%eax
801022c4:	74 0d                	je     801022d3 <dirlookup+0x4f>
      panic("dirlink read");
801022c6:	83 ec 0c             	sub    $0xc,%esp
801022c9:	68 cd 94 10 80       	push   $0x801094cd
801022ce:	e8 93 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022d3:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022d7:	66 85 c0             	test   %ax,%ax
801022da:	74 47                	je     80102323 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801022dc:	83 ec 08             	sub    $0x8,%esp
801022df:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e2:	83 c0 02             	add    $0x2,%eax
801022e5:	50                   	push   %eax
801022e6:	ff 75 0c             	pushl  0xc(%ebp)
801022e9:	e8 7b ff ff ff       	call   80102269 <namecmp>
801022ee:	83 c4 10             	add    $0x10,%esp
801022f1:	85 c0                	test   %eax,%eax
801022f3:	75 2f                	jne    80102324 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801022f5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022f9:	74 08                	je     80102303 <dirlookup+0x7f>
        *poff = off;
801022fb:	8b 45 10             	mov    0x10(%ebp),%eax
801022fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102301:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102303:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102307:	0f b7 c0             	movzwl %ax,%eax
8010230a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010230d:	8b 45 08             	mov    0x8(%ebp),%eax
80102310:	8b 00                	mov    (%eax),%eax
80102312:	83 ec 08             	sub    $0x8,%esp
80102315:	ff 75 f0             	pushl  -0x10(%ebp)
80102318:	50                   	push   %eax
80102319:	e8 e5 f5 ff ff       	call   80101903 <iget>
8010231e:	83 c4 10             	add    $0x10,%esp
80102321:	eb 19                	jmp    8010233c <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102323:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102324:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102328:	8b 45 08             	mov    0x8(%ebp),%eax
8010232b:	8b 40 18             	mov    0x18(%eax),%eax
8010232e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102331:	0f 87 76 ff ff ff    	ja     801022ad <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102337:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010233c:	c9                   	leave  
8010233d:	c3                   	ret    

8010233e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010233e:	55                   	push   %ebp
8010233f:	89 e5                	mov    %esp,%ebp
80102341:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102344:	83 ec 04             	sub    $0x4,%esp
80102347:	6a 00                	push   $0x0
80102349:	ff 75 0c             	pushl  0xc(%ebp)
8010234c:	ff 75 08             	pushl  0x8(%ebp)
8010234f:	e8 30 ff ff ff       	call   80102284 <dirlookup>
80102354:	83 c4 10             	add    $0x10,%esp
80102357:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010235a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010235e:	74 18                	je     80102378 <dirlink+0x3a>
    iput(ip);
80102360:	83 ec 0c             	sub    $0xc,%esp
80102363:	ff 75 f0             	pushl  -0x10(%ebp)
80102366:	e8 81 f8 ff ff       	call   80101bec <iput>
8010236b:	83 c4 10             	add    $0x10,%esp
    return -1;
8010236e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102373:	e9 9c 00 00 00       	jmp    80102414 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102378:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010237f:	eb 39                	jmp    801023ba <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102381:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102384:	6a 10                	push   $0x10
80102386:	50                   	push   %eax
80102387:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238a:	50                   	push   %eax
8010238b:	ff 75 08             	pushl  0x8(%ebp)
8010238e:	e8 f7 fb ff ff       	call   80101f8a <readi>
80102393:	83 c4 10             	add    $0x10,%esp
80102396:	83 f8 10             	cmp    $0x10,%eax
80102399:	74 0d                	je     801023a8 <dirlink+0x6a>
      panic("dirlink read");
8010239b:	83 ec 0c             	sub    $0xc,%esp
8010239e:	68 cd 94 10 80       	push   $0x801094cd
801023a3:	e8 be e1 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801023a8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023ac:	66 85 c0             	test   %ax,%ax
801023af:	74 18                	je     801023c9 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b4:	83 c0 10             	add    $0x10,%eax
801023b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023ba:	8b 45 08             	mov    0x8(%ebp),%eax
801023bd:	8b 50 18             	mov    0x18(%eax),%edx
801023c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023c3:	39 c2                	cmp    %eax,%edx
801023c5:	77 ba                	ja     80102381 <dirlink+0x43>
801023c7:	eb 01                	jmp    801023ca <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801023c9:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023ca:	83 ec 04             	sub    $0x4,%esp
801023cd:	6a 0e                	push   $0xe
801023cf:	ff 75 0c             	pushl  0xc(%ebp)
801023d2:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023d5:	83 c0 02             	add    $0x2,%eax
801023d8:	50                   	push   %eax
801023d9:	e8 e4 3c 00 00       	call   801060c2 <strncpy>
801023de:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023e1:	8b 45 10             	mov    0x10(%ebp),%eax
801023e4:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023eb:	6a 10                	push   $0x10
801023ed:	50                   	push   %eax
801023ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f1:	50                   	push   %eax
801023f2:	ff 75 08             	pushl  0x8(%ebp)
801023f5:	e8 e7 fc ff ff       	call   801020e1 <writei>
801023fa:	83 c4 10             	add    $0x10,%esp
801023fd:	83 f8 10             	cmp    $0x10,%eax
80102400:	74 0d                	je     8010240f <dirlink+0xd1>
    panic("dirlink");
80102402:	83 ec 0c             	sub    $0xc,%esp
80102405:	68 da 94 10 80       	push   $0x801094da
8010240a:	e8 57 e1 ff ff       	call   80100566 <panic>
  
  return 0;
8010240f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102414:	c9                   	leave  
80102415:	c3                   	ret    

80102416 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102416:	55                   	push   %ebp
80102417:	89 e5                	mov    %esp,%ebp
80102419:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010241c:	eb 04                	jmp    80102422 <skipelem+0xc>
    path++;
8010241e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102422:	8b 45 08             	mov    0x8(%ebp),%eax
80102425:	0f b6 00             	movzbl (%eax),%eax
80102428:	3c 2f                	cmp    $0x2f,%al
8010242a:	74 f2                	je     8010241e <skipelem+0x8>
    path++;
  if(*path == 0)
8010242c:	8b 45 08             	mov    0x8(%ebp),%eax
8010242f:	0f b6 00             	movzbl (%eax),%eax
80102432:	84 c0                	test   %al,%al
80102434:	75 07                	jne    8010243d <skipelem+0x27>
    return 0;
80102436:	b8 00 00 00 00       	mov    $0x0,%eax
8010243b:	eb 7b                	jmp    801024b8 <skipelem+0xa2>
  s = path;
8010243d:	8b 45 08             	mov    0x8(%ebp),%eax
80102440:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102443:	eb 04                	jmp    80102449 <skipelem+0x33>
    path++;
80102445:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102449:	8b 45 08             	mov    0x8(%ebp),%eax
8010244c:	0f b6 00             	movzbl (%eax),%eax
8010244f:	3c 2f                	cmp    $0x2f,%al
80102451:	74 0a                	je     8010245d <skipelem+0x47>
80102453:	8b 45 08             	mov    0x8(%ebp),%eax
80102456:	0f b6 00             	movzbl (%eax),%eax
80102459:	84 c0                	test   %al,%al
8010245b:	75 e8                	jne    80102445 <skipelem+0x2f>
    path++;
  len = path - s;
8010245d:	8b 55 08             	mov    0x8(%ebp),%edx
80102460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102463:	29 c2                	sub    %eax,%edx
80102465:	89 d0                	mov    %edx,%eax
80102467:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010246a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010246e:	7e 15                	jle    80102485 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102470:	83 ec 04             	sub    $0x4,%esp
80102473:	6a 0e                	push   $0xe
80102475:	ff 75 f4             	pushl  -0xc(%ebp)
80102478:	ff 75 0c             	pushl  0xc(%ebp)
8010247b:	e8 56 3b 00 00       	call   80105fd6 <memmove>
80102480:	83 c4 10             	add    $0x10,%esp
80102483:	eb 26                	jmp    801024ab <skipelem+0x95>
  else {
    memmove(name, s, len);
80102485:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102488:	83 ec 04             	sub    $0x4,%esp
8010248b:	50                   	push   %eax
8010248c:	ff 75 f4             	pushl  -0xc(%ebp)
8010248f:	ff 75 0c             	pushl  0xc(%ebp)
80102492:	e8 3f 3b 00 00       	call   80105fd6 <memmove>
80102497:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
8010249a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010249d:	8b 45 0c             	mov    0xc(%ebp),%eax
801024a0:	01 d0                	add    %edx,%eax
801024a2:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024a5:	eb 04                	jmp    801024ab <skipelem+0x95>
    path++;
801024a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024ab:	8b 45 08             	mov    0x8(%ebp),%eax
801024ae:	0f b6 00             	movzbl (%eax),%eax
801024b1:	3c 2f                	cmp    $0x2f,%al
801024b3:	74 f2                	je     801024a7 <skipelem+0x91>
    path++;
  return path;
801024b5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024b8:	c9                   	leave  
801024b9:	c3                   	ret    

801024ba <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024ba:	55                   	push   %ebp
801024bb:	89 e5                	mov    %esp,%ebp
801024bd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024c0:	8b 45 08             	mov    0x8(%ebp),%eax
801024c3:	0f b6 00             	movzbl (%eax),%eax
801024c6:	3c 2f                	cmp    $0x2f,%al
801024c8:	75 17                	jne    801024e1 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801024ca:	83 ec 08             	sub    $0x8,%esp
801024cd:	6a 01                	push   $0x1
801024cf:	6a 01                	push   $0x1
801024d1:	e8 2d f4 ff ff       	call   80101903 <iget>
801024d6:	83 c4 10             	add    $0x10,%esp
801024d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024dc:	e9 bb 00 00 00       	jmp    8010259c <namex+0xe2>
  else
    ip = idup(proc->cwd);
801024e1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801024e7:	8b 40 68             	mov    0x68(%eax),%eax
801024ea:	83 ec 0c             	sub    $0xc,%esp
801024ed:	50                   	push   %eax
801024ee:	e8 ef f4 ff ff       	call   801019e2 <idup>
801024f3:	83 c4 10             	add    $0x10,%esp
801024f6:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801024f9:	e9 9e 00 00 00       	jmp    8010259c <namex+0xe2>
    ilock(ip);
801024fe:	83 ec 0c             	sub    $0xc,%esp
80102501:	ff 75 f4             	pushl  -0xc(%ebp)
80102504:	e8 13 f5 ff ff       	call   80101a1c <ilock>
80102509:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010250c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010250f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102513:	66 83 f8 01          	cmp    $0x1,%ax
80102517:	74 18                	je     80102531 <namex+0x77>
      iunlockput(ip);
80102519:	83 ec 0c             	sub    $0xc,%esp
8010251c:	ff 75 f4             	pushl  -0xc(%ebp)
8010251f:	e8 b8 f7 ff ff       	call   80101cdc <iunlockput>
80102524:	83 c4 10             	add    $0x10,%esp
      return 0;
80102527:	b8 00 00 00 00       	mov    $0x0,%eax
8010252c:	e9 a7 00 00 00       	jmp    801025d8 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102531:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102535:	74 20                	je     80102557 <namex+0x9d>
80102537:	8b 45 08             	mov    0x8(%ebp),%eax
8010253a:	0f b6 00             	movzbl (%eax),%eax
8010253d:	84 c0                	test   %al,%al
8010253f:	75 16                	jne    80102557 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102541:	83 ec 0c             	sub    $0xc,%esp
80102544:	ff 75 f4             	pushl  -0xc(%ebp)
80102547:	e8 2e f6 ff ff       	call   80101b7a <iunlock>
8010254c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010254f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102552:	e9 81 00 00 00       	jmp    801025d8 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102557:	83 ec 04             	sub    $0x4,%esp
8010255a:	6a 00                	push   $0x0
8010255c:	ff 75 10             	pushl  0x10(%ebp)
8010255f:	ff 75 f4             	pushl  -0xc(%ebp)
80102562:	e8 1d fd ff ff       	call   80102284 <dirlookup>
80102567:	83 c4 10             	add    $0x10,%esp
8010256a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010256d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102571:	75 15                	jne    80102588 <namex+0xce>
      iunlockput(ip);
80102573:	83 ec 0c             	sub    $0xc,%esp
80102576:	ff 75 f4             	pushl  -0xc(%ebp)
80102579:	e8 5e f7 ff ff       	call   80101cdc <iunlockput>
8010257e:	83 c4 10             	add    $0x10,%esp
      return 0;
80102581:	b8 00 00 00 00       	mov    $0x0,%eax
80102586:	eb 50                	jmp    801025d8 <namex+0x11e>
    }
    iunlockput(ip);
80102588:	83 ec 0c             	sub    $0xc,%esp
8010258b:	ff 75 f4             	pushl  -0xc(%ebp)
8010258e:	e8 49 f7 ff ff       	call   80101cdc <iunlockput>
80102593:	83 c4 10             	add    $0x10,%esp
    ip = next;
80102596:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102599:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
8010259c:	83 ec 08             	sub    $0x8,%esp
8010259f:	ff 75 10             	pushl  0x10(%ebp)
801025a2:	ff 75 08             	pushl  0x8(%ebp)
801025a5:	e8 6c fe ff ff       	call   80102416 <skipelem>
801025aa:	83 c4 10             	add    $0x10,%esp
801025ad:	89 45 08             	mov    %eax,0x8(%ebp)
801025b0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025b4:	0f 85 44 ff ff ff    	jne    801024fe <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801025ba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025be:	74 15                	je     801025d5 <namex+0x11b>
    iput(ip);
801025c0:	83 ec 0c             	sub    $0xc,%esp
801025c3:	ff 75 f4             	pushl  -0xc(%ebp)
801025c6:	e8 21 f6 ff ff       	call   80101bec <iput>
801025cb:	83 c4 10             	add    $0x10,%esp
    return 0;
801025ce:	b8 00 00 00 00       	mov    $0x0,%eax
801025d3:	eb 03                	jmp    801025d8 <namex+0x11e>
  }
  return ip;
801025d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025d8:	c9                   	leave  
801025d9:	c3                   	ret    

801025da <namei>:

struct inode*
namei(char *path)
{
801025da:	55                   	push   %ebp
801025db:	89 e5                	mov    %esp,%ebp
801025dd:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801025e0:	83 ec 04             	sub    $0x4,%esp
801025e3:	8d 45 ea             	lea    -0x16(%ebp),%eax
801025e6:	50                   	push   %eax
801025e7:	6a 00                	push   $0x0
801025e9:	ff 75 08             	pushl  0x8(%ebp)
801025ec:	e8 c9 fe ff ff       	call   801024ba <namex>
801025f1:	83 c4 10             	add    $0x10,%esp
}
801025f4:	c9                   	leave  
801025f5:	c3                   	ret    

801025f6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025f6:	55                   	push   %ebp
801025f7:	89 e5                	mov    %esp,%ebp
801025f9:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801025fc:	83 ec 04             	sub    $0x4,%esp
801025ff:	ff 75 0c             	pushl  0xc(%ebp)
80102602:	6a 01                	push   $0x1
80102604:	ff 75 08             	pushl  0x8(%ebp)
80102607:	e8 ae fe ff ff       	call   801024ba <namex>
8010260c:	83 c4 10             	add    $0x10,%esp
}
8010260f:	c9                   	leave  
80102610:	c3                   	ret    

80102611 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102611:	55                   	push   %ebp
80102612:	89 e5                	mov    %esp,%ebp
80102614:	83 ec 14             	sub    $0x14,%esp
80102617:	8b 45 08             	mov    0x8(%ebp),%eax
8010261a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010261e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102622:	89 c2                	mov    %eax,%edx
80102624:	ec                   	in     (%dx),%al
80102625:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102628:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010262c:	c9                   	leave  
8010262d:	c3                   	ret    

8010262e <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
80102631:	57                   	push   %edi
80102632:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102633:	8b 55 08             	mov    0x8(%ebp),%edx
80102636:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102639:	8b 45 10             	mov    0x10(%ebp),%eax
8010263c:	89 cb                	mov    %ecx,%ebx
8010263e:	89 df                	mov    %ebx,%edi
80102640:	89 c1                	mov    %eax,%ecx
80102642:	fc                   	cld    
80102643:	f3 6d                	rep insl (%dx),%es:(%edi)
80102645:	89 c8                	mov    %ecx,%eax
80102647:	89 fb                	mov    %edi,%ebx
80102649:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010264c:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010264f:	90                   	nop
80102650:	5b                   	pop    %ebx
80102651:	5f                   	pop    %edi
80102652:	5d                   	pop    %ebp
80102653:	c3                   	ret    

80102654 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102654:	55                   	push   %ebp
80102655:	89 e5                	mov    %esp,%ebp
80102657:	83 ec 08             	sub    $0x8,%esp
8010265a:	8b 55 08             	mov    0x8(%ebp),%edx
8010265d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102660:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102664:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102667:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010266b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010266f:	ee                   	out    %al,(%dx)
}
80102670:	90                   	nop
80102671:	c9                   	leave  
80102672:	c3                   	ret    

80102673 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	56                   	push   %esi
80102677:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102678:	8b 55 08             	mov    0x8(%ebp),%edx
8010267b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010267e:	8b 45 10             	mov    0x10(%ebp),%eax
80102681:	89 cb                	mov    %ecx,%ebx
80102683:	89 de                	mov    %ebx,%esi
80102685:	89 c1                	mov    %eax,%ecx
80102687:	fc                   	cld    
80102688:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010268a:	89 c8                	mov    %ecx,%eax
8010268c:	89 f3                	mov    %esi,%ebx
8010268e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102691:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102694:	90                   	nop
80102695:	5b                   	pop    %ebx
80102696:	5e                   	pop    %esi
80102697:	5d                   	pop    %ebp
80102698:	c3                   	ret    

80102699 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102699:	55                   	push   %ebp
8010269a:	89 e5                	mov    %esp,%ebp
8010269c:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
8010269f:	90                   	nop
801026a0:	68 f7 01 00 00       	push   $0x1f7
801026a5:	e8 67 ff ff ff       	call   80102611 <inb>
801026aa:	83 c4 04             	add    $0x4,%esp
801026ad:	0f b6 c0             	movzbl %al,%eax
801026b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
801026b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026b6:	25 c0 00 00 00       	and    $0xc0,%eax
801026bb:	83 f8 40             	cmp    $0x40,%eax
801026be:	75 e0                	jne    801026a0 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801026c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c4:	74 11                	je     801026d7 <idewait+0x3e>
801026c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026c9:	83 e0 21             	and    $0x21,%eax
801026cc:	85 c0                	test   %eax,%eax
801026ce:	74 07                	je     801026d7 <idewait+0x3e>
    return -1;
801026d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801026d5:	eb 05                	jmp    801026dc <idewait+0x43>
  return 0;
801026d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801026dc:	c9                   	leave  
801026dd:	c3                   	ret    

801026de <ideinit>:

void
ideinit(void)
{
801026de:	55                   	push   %ebp
801026df:	89 e5                	mov    %esp,%ebp
801026e1:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
801026e4:	83 ec 08             	sub    $0x8,%esp
801026e7:	68 e2 94 10 80       	push   $0x801094e2
801026ec:	68 20 c6 10 80       	push   $0x8010c620
801026f1:	e8 9c 35 00 00       	call   80105c92 <initlock>
801026f6:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801026f9:	83 ec 0c             	sub    $0xc,%esp
801026fc:	6a 0e                	push   $0xe
801026fe:	e8 da 18 00 00       	call   80103fdd <picenable>
80102703:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102706:	a1 60 39 11 80       	mov    0x80113960,%eax
8010270b:	83 e8 01             	sub    $0x1,%eax
8010270e:	83 ec 08             	sub    $0x8,%esp
80102711:	50                   	push   %eax
80102712:	6a 0e                	push   $0xe
80102714:	e8 73 04 00 00       	call   80102b8c <ioapicenable>
80102719:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010271c:	83 ec 0c             	sub    $0xc,%esp
8010271f:	6a 00                	push   $0x0
80102721:	e8 73 ff ff ff       	call   80102699 <idewait>
80102726:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102729:	83 ec 08             	sub    $0x8,%esp
8010272c:	68 f0 00 00 00       	push   $0xf0
80102731:	68 f6 01 00 00       	push   $0x1f6
80102736:	e8 19 ff ff ff       	call   80102654 <outb>
8010273b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010273e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102745:	eb 24                	jmp    8010276b <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102747:	83 ec 0c             	sub    $0xc,%esp
8010274a:	68 f7 01 00 00       	push   $0x1f7
8010274f:	e8 bd fe ff ff       	call   80102611 <inb>
80102754:	83 c4 10             	add    $0x10,%esp
80102757:	84 c0                	test   %al,%al
80102759:	74 0c                	je     80102767 <ideinit+0x89>
      havedisk1 = 1;
8010275b:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
80102762:	00 00 00 
      break;
80102765:	eb 0d                	jmp    80102774 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102767:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010276b:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102772:	7e d3                	jle    80102747 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102774:	83 ec 08             	sub    $0x8,%esp
80102777:	68 e0 00 00 00       	push   $0xe0
8010277c:	68 f6 01 00 00       	push   $0x1f6
80102781:	e8 ce fe ff ff       	call   80102654 <outb>
80102786:	83 c4 10             	add    $0x10,%esp
}
80102789:	90                   	nop
8010278a:	c9                   	leave  
8010278b:	c3                   	ret    

8010278c <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010278c:	55                   	push   %ebp
8010278d:	89 e5                	mov    %esp,%ebp
8010278f:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102792:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102796:	75 0d                	jne    801027a5 <idestart+0x19>
    panic("idestart");
80102798:	83 ec 0c             	sub    $0xc,%esp
8010279b:	68 e6 94 10 80       	push   $0x801094e6
801027a0:	e8 c1 dd ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801027a5:	8b 45 08             	mov    0x8(%ebp),%eax
801027a8:	8b 40 08             	mov    0x8(%eax),%eax
801027ab:	3d cf 07 00 00       	cmp    $0x7cf,%eax
801027b0:	76 0d                	jbe    801027bf <idestart+0x33>
    panic("incorrect blockno");
801027b2:	83 ec 0c             	sub    $0xc,%esp
801027b5:	68 ef 94 10 80       	push   $0x801094ef
801027ba:	e8 a7 dd ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801027bf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801027c6:	8b 45 08             	mov    0x8(%ebp),%eax
801027c9:	8b 50 08             	mov    0x8(%eax),%edx
801027cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027cf:	0f af c2             	imul   %edx,%eax
801027d2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027d5:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027d9:	7e 0d                	jle    801027e8 <idestart+0x5c>
801027db:	83 ec 0c             	sub    $0xc,%esp
801027de:	68 e6 94 10 80       	push   $0x801094e6
801027e3:	e8 7e dd ff ff       	call   80100566 <panic>
  
  idewait(0);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	6a 00                	push   $0x0
801027ed:	e8 a7 fe ff ff       	call   80102699 <idewait>
801027f2:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
801027f5:	83 ec 08             	sub    $0x8,%esp
801027f8:	6a 00                	push   $0x0
801027fa:	68 f6 03 00 00       	push   $0x3f6
801027ff:	e8 50 fe ff ff       	call   80102654 <outb>
80102804:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010280a:	0f b6 c0             	movzbl %al,%eax
8010280d:	83 ec 08             	sub    $0x8,%esp
80102810:	50                   	push   %eax
80102811:	68 f2 01 00 00       	push   $0x1f2
80102816:	e8 39 fe ff ff       	call   80102654 <outb>
8010281b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010281e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102821:	0f b6 c0             	movzbl %al,%eax
80102824:	83 ec 08             	sub    $0x8,%esp
80102827:	50                   	push   %eax
80102828:	68 f3 01 00 00       	push   $0x1f3
8010282d:	e8 22 fe ff ff       	call   80102654 <outb>
80102832:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102835:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102838:	c1 f8 08             	sar    $0x8,%eax
8010283b:	0f b6 c0             	movzbl %al,%eax
8010283e:	83 ec 08             	sub    $0x8,%esp
80102841:	50                   	push   %eax
80102842:	68 f4 01 00 00       	push   $0x1f4
80102847:	e8 08 fe ff ff       	call   80102654 <outb>
8010284c:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010284f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102852:	c1 f8 10             	sar    $0x10,%eax
80102855:	0f b6 c0             	movzbl %al,%eax
80102858:	83 ec 08             	sub    $0x8,%esp
8010285b:	50                   	push   %eax
8010285c:	68 f5 01 00 00       	push   $0x1f5
80102861:	e8 ee fd ff ff       	call   80102654 <outb>
80102866:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102869:	8b 45 08             	mov    0x8(%ebp),%eax
8010286c:	8b 40 04             	mov    0x4(%eax),%eax
8010286f:	83 e0 01             	and    $0x1,%eax
80102872:	c1 e0 04             	shl    $0x4,%eax
80102875:	89 c2                	mov    %eax,%edx
80102877:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010287a:	c1 f8 18             	sar    $0x18,%eax
8010287d:	83 e0 0f             	and    $0xf,%eax
80102880:	09 d0                	or     %edx,%eax
80102882:	83 c8 e0             	or     $0xffffffe0,%eax
80102885:	0f b6 c0             	movzbl %al,%eax
80102888:	83 ec 08             	sub    $0x8,%esp
8010288b:	50                   	push   %eax
8010288c:	68 f6 01 00 00       	push   $0x1f6
80102891:	e8 be fd ff ff       	call   80102654 <outb>
80102896:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102899:	8b 45 08             	mov    0x8(%ebp),%eax
8010289c:	8b 00                	mov    (%eax),%eax
8010289e:	83 e0 04             	and    $0x4,%eax
801028a1:	85 c0                	test   %eax,%eax
801028a3:	74 30                	je     801028d5 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801028a5:	83 ec 08             	sub    $0x8,%esp
801028a8:	6a 30                	push   $0x30
801028aa:	68 f7 01 00 00       	push   $0x1f7
801028af:	e8 a0 fd ff ff       	call   80102654 <outb>
801028b4:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801028b7:	8b 45 08             	mov    0x8(%ebp),%eax
801028ba:	83 c0 18             	add    $0x18,%eax
801028bd:	83 ec 04             	sub    $0x4,%esp
801028c0:	68 80 00 00 00       	push   $0x80
801028c5:	50                   	push   %eax
801028c6:	68 f0 01 00 00       	push   $0x1f0
801028cb:	e8 a3 fd ff ff       	call   80102673 <outsl>
801028d0:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
801028d3:	eb 12                	jmp    801028e7 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
801028d5:	83 ec 08             	sub    $0x8,%esp
801028d8:	6a 20                	push   $0x20
801028da:	68 f7 01 00 00       	push   $0x1f7
801028df:	e8 70 fd ff ff       	call   80102654 <outb>
801028e4:	83 c4 10             	add    $0x10,%esp
  }
}
801028e7:	90                   	nop
801028e8:	c9                   	leave  
801028e9:	c3                   	ret    

801028ea <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028ea:	55                   	push   %ebp
801028eb:	89 e5                	mov    %esp,%ebp
801028ed:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028f0:	83 ec 0c             	sub    $0xc,%esp
801028f3:	68 20 c6 10 80       	push   $0x8010c620
801028f8:	e8 b7 33 00 00       	call   80105cb4 <acquire>
801028fd:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102900:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102905:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102908:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010290c:	75 15                	jne    80102923 <ideintr+0x39>
    release(&idelock);
8010290e:	83 ec 0c             	sub    $0xc,%esp
80102911:	68 20 c6 10 80       	push   $0x8010c620
80102916:	e8 00 34 00 00       	call   80105d1b <release>
8010291b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010291e:	e9 9a 00 00 00       	jmp    801029bd <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102926:	8b 40 14             	mov    0x14(%eax),%eax
80102929:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010292e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102931:	8b 00                	mov    (%eax),%eax
80102933:	83 e0 04             	and    $0x4,%eax
80102936:	85 c0                	test   %eax,%eax
80102938:	75 2d                	jne    80102967 <ideintr+0x7d>
8010293a:	83 ec 0c             	sub    $0xc,%esp
8010293d:	6a 01                	push   $0x1
8010293f:	e8 55 fd ff ff       	call   80102699 <idewait>
80102944:	83 c4 10             	add    $0x10,%esp
80102947:	85 c0                	test   %eax,%eax
80102949:	78 1c                	js     80102967 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010294b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294e:	83 c0 18             	add    $0x18,%eax
80102951:	83 ec 04             	sub    $0x4,%esp
80102954:	68 80 00 00 00       	push   $0x80
80102959:	50                   	push   %eax
8010295a:	68 f0 01 00 00       	push   $0x1f0
8010295f:	e8 ca fc ff ff       	call   8010262e <insl>
80102964:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102967:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010296a:	8b 00                	mov    (%eax),%eax
8010296c:	83 c8 02             	or     $0x2,%eax
8010296f:	89 c2                	mov    %eax,%edx
80102971:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102974:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102979:	8b 00                	mov    (%eax),%eax
8010297b:	83 e0 fb             	and    $0xfffffffb,%eax
8010297e:	89 c2                	mov    %eax,%edx
80102980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102983:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102985:	83 ec 0c             	sub    $0xc,%esp
80102988:	ff 75 f4             	pushl  -0xc(%ebp)
8010298b:	e8 8e 26 00 00       	call   8010501e <wakeup>
80102990:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102993:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102998:	85 c0                	test   %eax,%eax
8010299a:	74 11                	je     801029ad <ideintr+0xc3>
    idestart(idequeue);
8010299c:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801029a1:	83 ec 0c             	sub    $0xc,%esp
801029a4:	50                   	push   %eax
801029a5:	e8 e2 fd ff ff       	call   8010278c <idestart>
801029aa:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801029ad:	83 ec 0c             	sub    $0xc,%esp
801029b0:	68 20 c6 10 80       	push   $0x8010c620
801029b5:	e8 61 33 00 00       	call   80105d1b <release>
801029ba:	83 c4 10             	add    $0x10,%esp
}
801029bd:	c9                   	leave  
801029be:	c3                   	ret    

801029bf <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801029bf:	55                   	push   %ebp
801029c0:	89 e5                	mov    %esp,%ebp
801029c2:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801029c5:	8b 45 08             	mov    0x8(%ebp),%eax
801029c8:	8b 00                	mov    (%eax),%eax
801029ca:	83 e0 01             	and    $0x1,%eax
801029cd:	85 c0                	test   %eax,%eax
801029cf:	75 0d                	jne    801029de <iderw+0x1f>
    panic("iderw: buf not busy");
801029d1:	83 ec 0c             	sub    $0xc,%esp
801029d4:	68 01 95 10 80       	push   $0x80109501
801029d9:	e8 88 db ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029de:	8b 45 08             	mov    0x8(%ebp),%eax
801029e1:	8b 00                	mov    (%eax),%eax
801029e3:	83 e0 06             	and    $0x6,%eax
801029e6:	83 f8 02             	cmp    $0x2,%eax
801029e9:	75 0d                	jne    801029f8 <iderw+0x39>
    panic("iderw: nothing to do");
801029eb:	83 ec 0c             	sub    $0xc,%esp
801029ee:	68 15 95 10 80       	push   $0x80109515
801029f3:	e8 6e db ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801029f8:	8b 45 08             	mov    0x8(%ebp),%eax
801029fb:	8b 40 04             	mov    0x4(%eax),%eax
801029fe:	85 c0                	test   %eax,%eax
80102a00:	74 16                	je     80102a18 <iderw+0x59>
80102a02:	a1 58 c6 10 80       	mov    0x8010c658,%eax
80102a07:	85 c0                	test   %eax,%eax
80102a09:	75 0d                	jne    80102a18 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102a0b:	83 ec 0c             	sub    $0xc,%esp
80102a0e:	68 2a 95 10 80       	push   $0x8010952a
80102a13:	e8 4e db ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102a18:	83 ec 0c             	sub    $0xc,%esp
80102a1b:	68 20 c6 10 80       	push   $0x8010c620
80102a20:	e8 8f 32 00 00       	call   80105cb4 <acquire>
80102a25:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102a28:	8b 45 08             	mov    0x8(%ebp),%eax
80102a2b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102a32:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102a39:	eb 0b                	jmp    80102a46 <iderw+0x87>
80102a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3e:	8b 00                	mov    (%eax),%eax
80102a40:	83 c0 14             	add    $0x14,%eax
80102a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a49:	8b 00                	mov    (%eax),%eax
80102a4b:	85 c0                	test   %eax,%eax
80102a4d:	75 ec                	jne    80102a3b <iderw+0x7c>
    ;
  *pp = b;
80102a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a52:	8b 55 08             	mov    0x8(%ebp),%edx
80102a55:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102a57:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102a5c:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a5f:	75 23                	jne    80102a84 <iderw+0xc5>
    idestart(b);
80102a61:	83 ec 0c             	sub    $0xc,%esp
80102a64:	ff 75 08             	pushl  0x8(%ebp)
80102a67:	e8 20 fd ff ff       	call   8010278c <idestart>
80102a6c:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a6f:	eb 13                	jmp    80102a84 <iderw+0xc5>
    sleep(b, &idelock);
80102a71:	83 ec 08             	sub    $0x8,%esp
80102a74:	68 20 c6 10 80       	push   $0x8010c620
80102a79:	ff 75 08             	pushl  0x8(%ebp)
80102a7c:	e8 88 24 00 00       	call   80104f09 <sleep>
80102a81:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a84:	8b 45 08             	mov    0x8(%ebp),%eax
80102a87:	8b 00                	mov    (%eax),%eax
80102a89:	83 e0 06             	and    $0x6,%eax
80102a8c:	83 f8 02             	cmp    $0x2,%eax
80102a8f:	75 e0                	jne    80102a71 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
80102a91:	83 ec 0c             	sub    $0xc,%esp
80102a94:	68 20 c6 10 80       	push   $0x8010c620
80102a99:	e8 7d 32 00 00       	call   80105d1b <release>
80102a9e:	83 c4 10             	add    $0x10,%esp
}
80102aa1:	90                   	nop
80102aa2:	c9                   	leave  
80102aa3:	c3                   	ret    

80102aa4 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102aa4:	55                   	push   %ebp
80102aa5:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102aa7:	a1 34 32 11 80       	mov    0x80113234,%eax
80102aac:	8b 55 08             	mov    0x8(%ebp),%edx
80102aaf:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ab1:	a1 34 32 11 80       	mov    0x80113234,%eax
80102ab6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ab9:	5d                   	pop    %ebp
80102aba:	c3                   	ret    

80102abb <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102abb:	55                   	push   %ebp
80102abc:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102abe:	a1 34 32 11 80       	mov    0x80113234,%eax
80102ac3:	8b 55 08             	mov    0x8(%ebp),%edx
80102ac6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102ac8:	a1 34 32 11 80       	mov    0x80113234,%eax
80102acd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102ad0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102ad3:	90                   	nop
80102ad4:	5d                   	pop    %ebp
80102ad5:	c3                   	ret    

80102ad6 <ioapicinit>:

void
ioapicinit(void)
{
80102ad6:	55                   	push   %ebp
80102ad7:	89 e5                	mov    %esp,%ebp
80102ad9:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102adc:	a1 64 33 11 80       	mov    0x80113364,%eax
80102ae1:	85 c0                	test   %eax,%eax
80102ae3:	0f 84 a0 00 00 00    	je     80102b89 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ae9:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102af0:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102af3:	6a 01                	push   $0x1
80102af5:	e8 aa ff ff ff       	call   80102aa4 <ioapicread>
80102afa:	83 c4 04             	add    $0x4,%esp
80102afd:	c1 e8 10             	shr    $0x10,%eax
80102b00:	25 ff 00 00 00       	and    $0xff,%eax
80102b05:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102b08:	6a 00                	push   $0x0
80102b0a:	e8 95 ff ff ff       	call   80102aa4 <ioapicread>
80102b0f:	83 c4 04             	add    $0x4,%esp
80102b12:	c1 e8 18             	shr    $0x18,%eax
80102b15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102b18:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102b1f:	0f b6 c0             	movzbl %al,%eax
80102b22:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102b25:	74 10                	je     80102b37 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102b27:	83 ec 0c             	sub    $0xc,%esp
80102b2a:	68 48 95 10 80       	push   $0x80109548
80102b2f:	e8 92 d8 ff ff       	call   801003c6 <cprintf>
80102b34:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102b3e:	eb 3f                	jmp    80102b7f <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b43:	83 c0 20             	add    $0x20,%eax
80102b46:	0d 00 00 01 00       	or     $0x10000,%eax
80102b4b:	89 c2                	mov    %eax,%edx
80102b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b50:	83 c0 08             	add    $0x8,%eax
80102b53:	01 c0                	add    %eax,%eax
80102b55:	83 ec 08             	sub    $0x8,%esp
80102b58:	52                   	push   %edx
80102b59:	50                   	push   %eax
80102b5a:	e8 5c ff ff ff       	call   80102abb <ioapicwrite>
80102b5f:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b65:	83 c0 08             	add    $0x8,%eax
80102b68:	01 c0                	add    %eax,%eax
80102b6a:	83 c0 01             	add    $0x1,%eax
80102b6d:	83 ec 08             	sub    $0x8,%esp
80102b70:	6a 00                	push   $0x0
80102b72:	50                   	push   %eax
80102b73:	e8 43 ff ff ff       	call   80102abb <ioapicwrite>
80102b78:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b7b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b82:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b85:	7e b9                	jle    80102b40 <ioapicinit+0x6a>
80102b87:	eb 01                	jmp    80102b8a <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102b89:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b8a:	c9                   	leave  
80102b8b:	c3                   	ret    

80102b8c <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b8c:	55                   	push   %ebp
80102b8d:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102b8f:	a1 64 33 11 80       	mov    0x80113364,%eax
80102b94:	85 c0                	test   %eax,%eax
80102b96:	74 39                	je     80102bd1 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b98:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9b:	83 c0 20             	add    $0x20,%eax
80102b9e:	89 c2                	mov    %eax,%edx
80102ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba3:	83 c0 08             	add    $0x8,%eax
80102ba6:	01 c0                	add    %eax,%eax
80102ba8:	52                   	push   %edx
80102ba9:	50                   	push   %eax
80102baa:	e8 0c ff ff ff       	call   80102abb <ioapicwrite>
80102baf:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bb5:	c1 e0 18             	shl    $0x18,%eax
80102bb8:	89 c2                	mov    %eax,%edx
80102bba:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbd:	83 c0 08             	add    $0x8,%eax
80102bc0:	01 c0                	add    %eax,%eax
80102bc2:	83 c0 01             	add    $0x1,%eax
80102bc5:	52                   	push   %edx
80102bc6:	50                   	push   %eax
80102bc7:	e8 ef fe ff ff       	call   80102abb <ioapicwrite>
80102bcc:	83 c4 08             	add    $0x8,%esp
80102bcf:	eb 01                	jmp    80102bd2 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102bd1:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102bd2:	c9                   	leave  
80102bd3:	c3                   	ret    

80102bd4 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102bd4:	55                   	push   %ebp
80102bd5:	89 e5                	mov    %esp,%ebp
80102bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bda:	05 00 00 00 80       	add    $0x80000000,%eax
80102bdf:	5d                   	pop    %ebp
80102be0:	c3                   	ret    

80102be1 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102be1:	55                   	push   %ebp
80102be2:	89 e5                	mov    %esp,%ebp
80102be4:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102be7:	83 ec 08             	sub    $0x8,%esp
80102bea:	68 7a 95 10 80       	push   $0x8010957a
80102bef:	68 40 32 11 80       	push   $0x80113240
80102bf4:	e8 99 30 00 00       	call   80105c92 <initlock>
80102bf9:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102bfc:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102c03:	00 00 00 
  freerange(vstart, vend);
80102c06:	83 ec 08             	sub    $0x8,%esp
80102c09:	ff 75 0c             	pushl  0xc(%ebp)
80102c0c:	ff 75 08             	pushl  0x8(%ebp)
80102c0f:	e8 2a 00 00 00       	call   80102c3e <freerange>
80102c14:	83 c4 10             	add    $0x10,%esp
}
80102c17:	90                   	nop
80102c18:	c9                   	leave  
80102c19:	c3                   	ret    

80102c1a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c1a:	55                   	push   %ebp
80102c1b:	89 e5                	mov    %esp,%ebp
80102c1d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102c20:	83 ec 08             	sub    $0x8,%esp
80102c23:	ff 75 0c             	pushl  0xc(%ebp)
80102c26:	ff 75 08             	pushl  0x8(%ebp)
80102c29:	e8 10 00 00 00       	call   80102c3e <freerange>
80102c2e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102c31:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102c38:	00 00 00 
}
80102c3b:	90                   	nop
80102c3c:	c9                   	leave  
80102c3d:	c3                   	ret    

80102c3e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102c3e:	55                   	push   %ebp
80102c3f:	89 e5                	mov    %esp,%ebp
80102c41:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102c44:	8b 45 08             	mov    0x8(%ebp),%eax
80102c47:	05 ff 0f 00 00       	add    $0xfff,%eax
80102c4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c54:	eb 15                	jmp    80102c6b <freerange+0x2d>
    kfree(p);
80102c56:	83 ec 0c             	sub    $0xc,%esp
80102c59:	ff 75 f4             	pushl  -0xc(%ebp)
80102c5c:	e8 1a 00 00 00       	call   80102c7b <kfree>
80102c61:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102c64:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c6e:	05 00 10 00 00       	add    $0x1000,%eax
80102c73:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c76:	76 de                	jbe    80102c56 <freerange+0x18>
    kfree(p);
}
80102c78:	90                   	nop
80102c79:	c9                   	leave  
80102c7a:	c3                   	ret    

80102c7b <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c7b:	55                   	push   %ebp
80102c7c:	89 e5                	mov    %esp,%ebp
80102c7e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102c81:	8b 45 08             	mov    0x8(%ebp),%eax
80102c84:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c89:	85 c0                	test   %eax,%eax
80102c8b:	75 1b                	jne    80102ca8 <kfree+0x2d>
80102c8d:	81 7d 08 5c 67 11 80 	cmpl   $0x8011675c,0x8(%ebp)
80102c94:	72 12                	jb     80102ca8 <kfree+0x2d>
80102c96:	ff 75 08             	pushl  0x8(%ebp)
80102c99:	e8 36 ff ff ff       	call   80102bd4 <v2p>
80102c9e:	83 c4 04             	add    $0x4,%esp
80102ca1:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102ca6:	76 0d                	jbe    80102cb5 <kfree+0x3a>
    panic("kfree");
80102ca8:	83 ec 0c             	sub    $0xc,%esp
80102cab:	68 7f 95 10 80       	push   $0x8010957f
80102cb0:	e8 b1 d8 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102cb5:	83 ec 04             	sub    $0x4,%esp
80102cb8:	68 00 10 00 00       	push   $0x1000
80102cbd:	6a 01                	push   $0x1
80102cbf:	ff 75 08             	pushl  0x8(%ebp)
80102cc2:	e8 50 32 00 00       	call   80105f17 <memset>
80102cc7:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102cca:	a1 74 32 11 80       	mov    0x80113274,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	74 10                	je     80102ce3 <kfree+0x68>
    acquire(&kmem.lock);
80102cd3:	83 ec 0c             	sub    $0xc,%esp
80102cd6:	68 40 32 11 80       	push   $0x80113240
80102cdb:	e8 d4 2f 00 00       	call   80105cb4 <acquire>
80102ce0:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102ce9:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf7:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102cfc:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d01:	85 c0                	test   %eax,%eax
80102d03:	74 10                	je     80102d15 <kfree+0x9a>
    release(&kmem.lock);
80102d05:	83 ec 0c             	sub    $0xc,%esp
80102d08:	68 40 32 11 80       	push   $0x80113240
80102d0d:	e8 09 30 00 00       	call   80105d1b <release>
80102d12:	83 c4 10             	add    $0x10,%esp
}
80102d15:	90                   	nop
80102d16:	c9                   	leave  
80102d17:	c3                   	ret    

80102d18 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d18:	55                   	push   %ebp
80102d19:	89 e5                	mov    %esp,%ebp
80102d1b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102d1e:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d23:	85 c0                	test   %eax,%eax
80102d25:	74 10                	je     80102d37 <kalloc+0x1f>
    acquire(&kmem.lock);
80102d27:	83 ec 0c             	sub    $0xc,%esp
80102d2a:	68 40 32 11 80       	push   $0x80113240
80102d2f:	e8 80 2f 00 00       	call   80105cb4 <acquire>
80102d34:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102d37:	a1 78 32 11 80       	mov    0x80113278,%eax
80102d3c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102d3f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102d43:	74 0a                	je     80102d4f <kalloc+0x37>
    kmem.freelist = r->next;
80102d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d48:	8b 00                	mov    (%eax),%eax
80102d4a:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102d4f:	a1 74 32 11 80       	mov    0x80113274,%eax
80102d54:	85 c0                	test   %eax,%eax
80102d56:	74 10                	je     80102d68 <kalloc+0x50>
    release(&kmem.lock);
80102d58:	83 ec 0c             	sub    $0xc,%esp
80102d5b:	68 40 32 11 80       	push   $0x80113240
80102d60:	e8 b6 2f 00 00       	call   80105d1b <release>
80102d65:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102d6b:	c9                   	leave  
80102d6c:	c3                   	ret    

80102d6d <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102d6d:	55                   	push   %ebp
80102d6e:	89 e5                	mov    %esp,%ebp
80102d70:	83 ec 14             	sub    $0x14,%esp
80102d73:	8b 45 08             	mov    0x8(%ebp),%eax
80102d76:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d7a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d7e:	89 c2                	mov    %eax,%edx
80102d80:	ec                   	in     (%dx),%al
80102d81:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d84:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d88:	c9                   	leave  
80102d89:	c3                   	ret    

80102d8a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d8a:	55                   	push   %ebp
80102d8b:	89 e5                	mov    %esp,%ebp
80102d8d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d90:	6a 64                	push   $0x64
80102d92:	e8 d6 ff ff ff       	call   80102d6d <inb>
80102d97:	83 c4 04             	add    $0x4,%esp
80102d9a:	0f b6 c0             	movzbl %al,%eax
80102d9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102da3:	83 e0 01             	and    $0x1,%eax
80102da6:	85 c0                	test   %eax,%eax
80102da8:	75 0a                	jne    80102db4 <kbdgetc+0x2a>
    return -1;
80102daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102daf:	e9 23 01 00 00       	jmp    80102ed7 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102db4:	6a 60                	push   $0x60
80102db6:	e8 b2 ff ff ff       	call   80102d6d <inb>
80102dbb:	83 c4 04             	add    $0x4,%esp
80102dbe:	0f b6 c0             	movzbl %al,%eax
80102dc1:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102dc4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102dcb:	75 17                	jne    80102de4 <kbdgetc+0x5a>
    shift |= E0ESC;
80102dcd:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dd2:	83 c8 40             	or     $0x40,%eax
80102dd5:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102dda:	b8 00 00 00 00       	mov    $0x0,%eax
80102ddf:	e9 f3 00 00 00       	jmp    80102ed7 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102de4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de7:	25 80 00 00 00       	and    $0x80,%eax
80102dec:	85 c0                	test   %eax,%eax
80102dee:	74 45                	je     80102e35 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102df0:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102df5:	83 e0 40             	and    $0x40,%eax
80102df8:	85 c0                	test   %eax,%eax
80102dfa:	75 08                	jne    80102e04 <kbdgetc+0x7a>
80102dfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dff:	83 e0 7f             	and    $0x7f,%eax
80102e02:	eb 03                	jmp    80102e07 <kbdgetc+0x7d>
80102e04:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e07:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e0d:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e12:	0f b6 00             	movzbl (%eax),%eax
80102e15:	83 c8 40             	or     $0x40,%eax
80102e18:	0f b6 c0             	movzbl %al,%eax
80102e1b:	f7 d0                	not    %eax
80102e1d:	89 c2                	mov    %eax,%edx
80102e1f:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e24:	21 d0                	and    %edx,%eax
80102e26:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102e2b:	b8 00 00 00 00       	mov    $0x0,%eax
80102e30:	e9 a2 00 00 00       	jmp    80102ed7 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e35:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e3a:	83 e0 40             	and    $0x40,%eax
80102e3d:	85 c0                	test   %eax,%eax
80102e3f:	74 14                	je     80102e55 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102e41:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102e48:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e4d:	83 e0 bf             	and    $0xffffffbf,%eax
80102e50:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102e55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e58:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e5d:	0f b6 00             	movzbl (%eax),%eax
80102e60:	0f b6 d0             	movzbl %al,%edx
80102e63:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e68:	09 d0                	or     %edx,%eax
80102e6a:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102e6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e72:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102e77:	0f b6 00             	movzbl (%eax),%eax
80102e7a:	0f b6 d0             	movzbl %al,%edx
80102e7d:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e82:	31 d0                	xor    %edx,%eax
80102e84:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e89:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102e8e:	83 e0 03             	and    $0x3,%eax
80102e91:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102e98:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e9b:	01 d0                	add    %edx,%eax
80102e9d:	0f b6 00             	movzbl (%eax),%eax
80102ea0:	0f b6 c0             	movzbl %al,%eax
80102ea3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ea6:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102eab:	83 e0 08             	and    $0x8,%eax
80102eae:	85 c0                	test   %eax,%eax
80102eb0:	74 22                	je     80102ed4 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102eb2:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102eb6:	76 0c                	jbe    80102ec4 <kbdgetc+0x13a>
80102eb8:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102ebc:	77 06                	ja     80102ec4 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102ebe:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102ec2:	eb 10                	jmp    80102ed4 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102ec4:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102ec8:	76 0a                	jbe    80102ed4 <kbdgetc+0x14a>
80102eca:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102ece:	77 04                	ja     80102ed4 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102ed0:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102ed4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ed7:	c9                   	leave  
80102ed8:	c3                   	ret    

80102ed9 <kbdintr>:

void
kbdintr(void)
{
80102ed9:	55                   	push   %ebp
80102eda:	89 e5                	mov    %esp,%ebp
80102edc:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102edf:	83 ec 0c             	sub    $0xc,%esp
80102ee2:	68 8a 2d 10 80       	push   $0x80102d8a
80102ee7:	e8 0d d9 ff ff       	call   801007f9 <consoleintr>
80102eec:	83 c4 10             	add    $0x10,%esp
}
80102eef:	90                   	nop
80102ef0:	c9                   	leave  
80102ef1:	c3                   	ret    

80102ef2 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102ef2:	55                   	push   %ebp
80102ef3:	89 e5                	mov    %esp,%ebp
80102ef5:	83 ec 14             	sub    $0x14,%esp
80102ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80102efb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eff:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102f03:	89 c2                	mov    %eax,%edx
80102f05:	ec                   	in     (%dx),%al
80102f06:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f09:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102f0d:	c9                   	leave  
80102f0e:	c3                   	ret    

80102f0f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f0f:	55                   	push   %ebp
80102f10:	89 e5                	mov    %esp,%ebp
80102f12:	83 ec 08             	sub    $0x8,%esp
80102f15:	8b 55 08             	mov    0x8(%ebp),%edx
80102f18:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f1b:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102f1f:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f22:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102f26:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102f2a:	ee                   	out    %al,(%dx)
}
80102f2b:	90                   	nop
80102f2c:	c9                   	leave  
80102f2d:	c3                   	ret    

80102f2e <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102f2e:	55                   	push   %ebp
80102f2f:	89 e5                	mov    %esp,%ebp
80102f31:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102f34:	9c                   	pushf  
80102f35:	58                   	pop    %eax
80102f36:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102f39:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102f3e:	55                   	push   %ebp
80102f3f:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f41:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f46:	8b 55 08             	mov    0x8(%ebp),%edx
80102f49:	c1 e2 02             	shl    $0x2,%edx
80102f4c:	01 c2                	add    %eax,%edx
80102f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f51:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102f53:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f58:	83 c0 20             	add    $0x20,%eax
80102f5b:	8b 00                	mov    (%eax),%eax
}
80102f5d:	90                   	nop
80102f5e:	5d                   	pop    %ebp
80102f5f:	c3                   	ret    

80102f60 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102f60:	55                   	push   %ebp
80102f61:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102f63:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f68:	85 c0                	test   %eax,%eax
80102f6a:	0f 84 0b 01 00 00    	je     8010307b <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102f70:	68 3f 01 00 00       	push   $0x13f
80102f75:	6a 3c                	push   $0x3c
80102f77:	e8 c2 ff ff ff       	call   80102f3e <lapicw>
80102f7c:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102f7f:	6a 0b                	push   $0xb
80102f81:	68 f8 00 00 00       	push   $0xf8
80102f86:	e8 b3 ff ff ff       	call   80102f3e <lapicw>
80102f8b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f8e:	68 20 00 02 00       	push   $0x20020
80102f93:	68 c8 00 00 00       	push   $0xc8
80102f98:	e8 a1 ff ff ff       	call   80102f3e <lapicw>
80102f9d:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80102fa0:	68 40 42 0f 00       	push   $0xf4240
80102fa5:	68 e0 00 00 00       	push   $0xe0
80102faa:	e8 8f ff ff ff       	call   80102f3e <lapicw>
80102faf:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102fb2:	68 00 00 01 00       	push   $0x10000
80102fb7:	68 d4 00 00 00       	push   $0xd4
80102fbc:	e8 7d ff ff ff       	call   80102f3e <lapicw>
80102fc1:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102fc4:	68 00 00 01 00       	push   $0x10000
80102fc9:	68 d8 00 00 00       	push   $0xd8
80102fce:	e8 6b ff ff ff       	call   80102f3e <lapicw>
80102fd3:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102fd6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fdb:	83 c0 30             	add    $0x30,%eax
80102fde:	8b 00                	mov    (%eax),%eax
80102fe0:	c1 e8 10             	shr    $0x10,%eax
80102fe3:	0f b6 c0             	movzbl %al,%eax
80102fe6:	83 f8 03             	cmp    $0x3,%eax
80102fe9:	76 12                	jbe    80102ffd <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102feb:	68 00 00 01 00       	push   $0x10000
80102ff0:	68 d0 00 00 00       	push   $0xd0
80102ff5:	e8 44 ff ff ff       	call   80102f3e <lapicw>
80102ffa:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102ffd:	6a 33                	push   $0x33
80102fff:	68 dc 00 00 00       	push   $0xdc
80103004:	e8 35 ff ff ff       	call   80102f3e <lapicw>
80103009:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010300c:	6a 00                	push   $0x0
8010300e:	68 a0 00 00 00       	push   $0xa0
80103013:	e8 26 ff ff ff       	call   80102f3e <lapicw>
80103018:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010301b:	6a 00                	push   $0x0
8010301d:	68 a0 00 00 00       	push   $0xa0
80103022:	e8 17 ff ff ff       	call   80102f3e <lapicw>
80103027:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010302a:	6a 00                	push   $0x0
8010302c:	6a 2c                	push   $0x2c
8010302e:	e8 0b ff ff ff       	call   80102f3e <lapicw>
80103033:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103036:	6a 00                	push   $0x0
80103038:	68 c4 00 00 00       	push   $0xc4
8010303d:	e8 fc fe ff ff       	call   80102f3e <lapicw>
80103042:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103045:	68 00 85 08 00       	push   $0x88500
8010304a:	68 c0 00 00 00       	push   $0xc0
8010304f:	e8 ea fe ff ff       	call   80102f3e <lapicw>
80103054:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103057:	90                   	nop
80103058:	a1 7c 32 11 80       	mov    0x8011327c,%eax
8010305d:	05 00 03 00 00       	add    $0x300,%eax
80103062:	8b 00                	mov    (%eax),%eax
80103064:	25 00 10 00 00       	and    $0x1000,%eax
80103069:	85 c0                	test   %eax,%eax
8010306b:	75 eb                	jne    80103058 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010306d:	6a 00                	push   $0x0
8010306f:	6a 20                	push   $0x20
80103071:	e8 c8 fe ff ff       	call   80102f3e <lapicw>
80103076:	83 c4 08             	add    $0x8,%esp
80103079:	eb 01                	jmp    8010307c <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
8010307b:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
8010307c:	c9                   	leave  
8010307d:	c3                   	ret    

8010307e <cpunum>:

int
cpunum(void)
{
8010307e:	55                   	push   %ebp
8010307f:	89 e5                	mov    %esp,%ebp
80103081:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103084:	e8 a5 fe ff ff       	call   80102f2e <readeflags>
80103089:	25 00 02 00 00       	and    $0x200,%eax
8010308e:	85 c0                	test   %eax,%eax
80103090:	74 26                	je     801030b8 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103092:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80103097:	8d 50 01             	lea    0x1(%eax),%edx
8010309a:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
801030a0:	85 c0                	test   %eax,%eax
801030a2:	75 14                	jne    801030b8 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
801030a4:	8b 45 04             	mov    0x4(%ebp),%eax
801030a7:	83 ec 08             	sub    $0x8,%esp
801030aa:	50                   	push   %eax
801030ab:	68 88 95 10 80       	push   $0x80109588
801030b0:	e8 11 d3 ff ff       	call   801003c6 <cprintf>
801030b5:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801030b8:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030bd:	85 c0                	test   %eax,%eax
801030bf:	74 0f                	je     801030d0 <cpunum+0x52>
    return lapic[ID]>>24;
801030c1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030c6:	83 c0 20             	add    $0x20,%eax
801030c9:	8b 00                	mov    (%eax),%eax
801030cb:	c1 e8 18             	shr    $0x18,%eax
801030ce:	eb 05                	jmp    801030d5 <cpunum+0x57>
  return 0;
801030d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801030d5:	c9                   	leave  
801030d6:	c3                   	ret    

801030d7 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801030d7:	55                   	push   %ebp
801030d8:	89 e5                	mov    %esp,%ebp
  if(lapic)
801030da:	a1 7c 32 11 80       	mov    0x8011327c,%eax
801030df:	85 c0                	test   %eax,%eax
801030e1:	74 0c                	je     801030ef <lapiceoi+0x18>
    lapicw(EOI, 0);
801030e3:	6a 00                	push   $0x0
801030e5:	6a 2c                	push   $0x2c
801030e7:	e8 52 fe ff ff       	call   80102f3e <lapicw>
801030ec:	83 c4 08             	add    $0x8,%esp
}
801030ef:	90                   	nop
801030f0:	c9                   	leave  
801030f1:	c3                   	ret    

801030f2 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801030f2:	55                   	push   %ebp
801030f3:	89 e5                	mov    %esp,%ebp
}
801030f5:	90                   	nop
801030f6:	5d                   	pop    %ebp
801030f7:	c3                   	ret    

801030f8 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801030f8:	55                   	push   %ebp
801030f9:	89 e5                	mov    %esp,%ebp
801030fb:	83 ec 14             	sub    $0x14,%esp
801030fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103101:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103104:	6a 0f                	push   $0xf
80103106:	6a 70                	push   $0x70
80103108:	e8 02 fe ff ff       	call   80102f0f <outb>
8010310d:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103110:	6a 0a                	push   $0xa
80103112:	6a 71                	push   $0x71
80103114:	e8 f6 fd ff ff       	call   80102f0f <outb>
80103119:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010311c:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103123:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103126:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010312b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010312e:	83 c0 02             	add    $0x2,%eax
80103131:	8b 55 0c             	mov    0xc(%ebp),%edx
80103134:	c1 ea 04             	shr    $0x4,%edx
80103137:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010313a:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010313e:	c1 e0 18             	shl    $0x18,%eax
80103141:	50                   	push   %eax
80103142:	68 c4 00 00 00       	push   $0xc4
80103147:	e8 f2 fd ff ff       	call   80102f3e <lapicw>
8010314c:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010314f:	68 00 c5 00 00       	push   $0xc500
80103154:	68 c0 00 00 00       	push   $0xc0
80103159:	e8 e0 fd ff ff       	call   80102f3e <lapicw>
8010315e:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103161:	68 c8 00 00 00       	push   $0xc8
80103166:	e8 87 ff ff ff       	call   801030f2 <microdelay>
8010316b:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010316e:	68 00 85 00 00       	push   $0x8500
80103173:	68 c0 00 00 00       	push   $0xc0
80103178:	e8 c1 fd ff ff       	call   80102f3e <lapicw>
8010317d:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103180:	6a 64                	push   $0x64
80103182:	e8 6b ff ff ff       	call   801030f2 <microdelay>
80103187:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010318a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103191:	eb 3d                	jmp    801031d0 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103193:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103197:	c1 e0 18             	shl    $0x18,%eax
8010319a:	50                   	push   %eax
8010319b:	68 c4 00 00 00       	push   $0xc4
801031a0:	e8 99 fd ff ff       	call   80102f3e <lapicw>
801031a5:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801031a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801031ab:	c1 e8 0c             	shr    $0xc,%eax
801031ae:	80 cc 06             	or     $0x6,%ah
801031b1:	50                   	push   %eax
801031b2:	68 c0 00 00 00       	push   $0xc0
801031b7:	e8 82 fd ff ff       	call   80102f3e <lapicw>
801031bc:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801031bf:	68 c8 00 00 00       	push   $0xc8
801031c4:	e8 29 ff ff ff       	call   801030f2 <microdelay>
801031c9:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031cc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801031d0:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801031d4:	7e bd                	jle    80103193 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801031d6:	90                   	nop
801031d7:	c9                   	leave  
801031d8:	c3                   	ret    

801031d9 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801031d9:	55                   	push   %ebp
801031da:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
801031dc:	8b 45 08             	mov    0x8(%ebp),%eax
801031df:	0f b6 c0             	movzbl %al,%eax
801031e2:	50                   	push   %eax
801031e3:	6a 70                	push   $0x70
801031e5:	e8 25 fd ff ff       	call   80102f0f <outb>
801031ea:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801031ed:	68 c8 00 00 00       	push   $0xc8
801031f2:	e8 fb fe ff ff       	call   801030f2 <microdelay>
801031f7:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801031fa:	6a 71                	push   $0x71
801031fc:	e8 f1 fc ff ff       	call   80102ef2 <inb>
80103201:	83 c4 04             	add    $0x4,%esp
80103204:	0f b6 c0             	movzbl %al,%eax
}
80103207:	c9                   	leave  
80103208:	c3                   	ret    

80103209 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103209:	55                   	push   %ebp
8010320a:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010320c:	6a 00                	push   $0x0
8010320e:	e8 c6 ff ff ff       	call   801031d9 <cmos_read>
80103213:	83 c4 04             	add    $0x4,%esp
80103216:	89 c2                	mov    %eax,%edx
80103218:	8b 45 08             	mov    0x8(%ebp),%eax
8010321b:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010321d:	6a 02                	push   $0x2
8010321f:	e8 b5 ff ff ff       	call   801031d9 <cmos_read>
80103224:	83 c4 04             	add    $0x4,%esp
80103227:	89 c2                	mov    %eax,%edx
80103229:	8b 45 08             	mov    0x8(%ebp),%eax
8010322c:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010322f:	6a 04                	push   $0x4
80103231:	e8 a3 ff ff ff       	call   801031d9 <cmos_read>
80103236:	83 c4 04             	add    $0x4,%esp
80103239:	89 c2                	mov    %eax,%edx
8010323b:	8b 45 08             	mov    0x8(%ebp),%eax
8010323e:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103241:	6a 07                	push   $0x7
80103243:	e8 91 ff ff ff       	call   801031d9 <cmos_read>
80103248:	83 c4 04             	add    $0x4,%esp
8010324b:	89 c2                	mov    %eax,%edx
8010324d:	8b 45 08             	mov    0x8(%ebp),%eax
80103250:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103253:	6a 08                	push   $0x8
80103255:	e8 7f ff ff ff       	call   801031d9 <cmos_read>
8010325a:	83 c4 04             	add    $0x4,%esp
8010325d:	89 c2                	mov    %eax,%edx
8010325f:	8b 45 08             	mov    0x8(%ebp),%eax
80103262:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103265:	6a 09                	push   $0x9
80103267:	e8 6d ff ff ff       	call   801031d9 <cmos_read>
8010326c:	83 c4 04             	add    $0x4,%esp
8010326f:	89 c2                	mov    %eax,%edx
80103271:	8b 45 08             	mov    0x8(%ebp),%eax
80103274:	89 50 14             	mov    %edx,0x14(%eax)
}
80103277:	90                   	nop
80103278:	c9                   	leave  
80103279:	c3                   	ret    

8010327a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010327a:	55                   	push   %ebp
8010327b:	89 e5                	mov    %esp,%ebp
8010327d:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103280:	6a 0b                	push   $0xb
80103282:	e8 52 ff ff ff       	call   801031d9 <cmos_read>
80103287:	83 c4 04             	add    $0x4,%esp
8010328a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010328d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103290:	83 e0 04             	and    $0x4,%eax
80103293:	85 c0                	test   %eax,%eax
80103295:	0f 94 c0             	sete   %al
80103298:	0f b6 c0             	movzbl %al,%eax
8010329b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010329e:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032a1:	50                   	push   %eax
801032a2:	e8 62 ff ff ff       	call   80103209 <fill_rtcdate>
801032a7:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801032aa:	6a 0a                	push   $0xa
801032ac:	e8 28 ff ff ff       	call   801031d9 <cmos_read>
801032b1:	83 c4 04             	add    $0x4,%esp
801032b4:	25 80 00 00 00       	and    $0x80,%eax
801032b9:	85 c0                	test   %eax,%eax
801032bb:	75 27                	jne    801032e4 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801032bd:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032c0:	50                   	push   %eax
801032c1:	e8 43 ff ff ff       	call   80103209 <fill_rtcdate>
801032c6:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801032c9:	83 ec 04             	sub    $0x4,%esp
801032cc:	6a 18                	push   $0x18
801032ce:	8d 45 c0             	lea    -0x40(%ebp),%eax
801032d1:	50                   	push   %eax
801032d2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801032d5:	50                   	push   %eax
801032d6:	e8 a3 2c 00 00       	call   80105f7e <memcmp>
801032db:	83 c4 10             	add    $0x10,%esp
801032de:	85 c0                	test   %eax,%eax
801032e0:	74 05                	je     801032e7 <cmostime+0x6d>
801032e2:	eb ba                	jmp    8010329e <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
801032e4:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801032e5:	eb b7                	jmp    8010329e <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
801032e7:	90                   	nop
  }

  // convert
  if (bcd) {
801032e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801032ec:	0f 84 b4 00 00 00    	je     801033a6 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801032f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032f5:	c1 e8 04             	shr    $0x4,%eax
801032f8:	89 c2                	mov    %eax,%edx
801032fa:	89 d0                	mov    %edx,%eax
801032fc:	c1 e0 02             	shl    $0x2,%eax
801032ff:	01 d0                	add    %edx,%eax
80103301:	01 c0                	add    %eax,%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103308:	83 e0 0f             	and    $0xf,%eax
8010330b:	01 d0                	add    %edx,%eax
8010330d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103310:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103313:	c1 e8 04             	shr    $0x4,%eax
80103316:	89 c2                	mov    %eax,%edx
80103318:	89 d0                	mov    %edx,%eax
8010331a:	c1 e0 02             	shl    $0x2,%eax
8010331d:	01 d0                	add    %edx,%eax
8010331f:	01 c0                	add    %eax,%eax
80103321:	89 c2                	mov    %eax,%edx
80103323:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103326:	83 e0 0f             	and    $0xf,%eax
80103329:	01 d0                	add    %edx,%eax
8010332b:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010332e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103331:	c1 e8 04             	shr    $0x4,%eax
80103334:	89 c2                	mov    %eax,%edx
80103336:	89 d0                	mov    %edx,%eax
80103338:	c1 e0 02             	shl    $0x2,%eax
8010333b:	01 d0                	add    %edx,%eax
8010333d:	01 c0                	add    %eax,%eax
8010333f:	89 c2                	mov    %eax,%edx
80103341:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103344:	83 e0 0f             	and    $0xf,%eax
80103347:	01 d0                	add    %edx,%eax
80103349:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010334c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010334f:	c1 e8 04             	shr    $0x4,%eax
80103352:	89 c2                	mov    %eax,%edx
80103354:	89 d0                	mov    %edx,%eax
80103356:	c1 e0 02             	shl    $0x2,%eax
80103359:	01 d0                	add    %edx,%eax
8010335b:	01 c0                	add    %eax,%eax
8010335d:	89 c2                	mov    %eax,%edx
8010335f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103362:	83 e0 0f             	and    $0xf,%eax
80103365:	01 d0                	add    %edx,%eax
80103367:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010336a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010336d:	c1 e8 04             	shr    $0x4,%eax
80103370:	89 c2                	mov    %eax,%edx
80103372:	89 d0                	mov    %edx,%eax
80103374:	c1 e0 02             	shl    $0x2,%eax
80103377:	01 d0                	add    %edx,%eax
80103379:	01 c0                	add    %eax,%eax
8010337b:	89 c2                	mov    %eax,%edx
8010337d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103380:	83 e0 0f             	and    $0xf,%eax
80103383:	01 d0                	add    %edx,%eax
80103385:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103388:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010338b:	c1 e8 04             	shr    $0x4,%eax
8010338e:	89 c2                	mov    %eax,%edx
80103390:	89 d0                	mov    %edx,%eax
80103392:	c1 e0 02             	shl    $0x2,%eax
80103395:	01 d0                	add    %edx,%eax
80103397:	01 c0                	add    %eax,%eax
80103399:	89 c2                	mov    %eax,%edx
8010339b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010339e:	83 e0 0f             	and    $0xf,%eax
801033a1:	01 d0                	add    %edx,%eax
801033a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801033a6:	8b 45 08             	mov    0x8(%ebp),%eax
801033a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033ac:	89 10                	mov    %edx,(%eax)
801033ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
801033b1:	89 50 04             	mov    %edx,0x4(%eax)
801033b4:	8b 55 e0             	mov    -0x20(%ebp),%edx
801033b7:	89 50 08             	mov    %edx,0x8(%eax)
801033ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801033bd:	89 50 0c             	mov    %edx,0xc(%eax)
801033c0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801033c3:	89 50 10             	mov    %edx,0x10(%eax)
801033c6:	8b 55 ec             	mov    -0x14(%ebp),%edx
801033c9:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801033cc:	8b 45 08             	mov    0x8(%ebp),%eax
801033cf:	8b 40 14             	mov    0x14(%eax),%eax
801033d2:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801033d8:	8b 45 08             	mov    0x8(%ebp),%eax
801033db:	89 50 14             	mov    %edx,0x14(%eax)
}
801033de:	90                   	nop
801033df:	c9                   	leave  
801033e0:	c3                   	ret    

801033e1 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801033e1:	55                   	push   %ebp
801033e2:	89 e5                	mov    %esp,%ebp
801033e4:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801033e7:	83 ec 08             	sub    $0x8,%esp
801033ea:	68 b4 95 10 80       	push   $0x801095b4
801033ef:	68 80 32 11 80       	push   $0x80113280
801033f4:	e8 99 28 00 00       	call   80105c92 <initlock>
801033f9:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801033fc:	83 ec 08             	sub    $0x8,%esp
801033ff:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103402:	50                   	push   %eax
80103403:	ff 75 08             	pushl  0x8(%ebp)
80103406:	e8 2b e0 ff ff       	call   80101436 <readsb>
8010340b:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010340e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103411:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
80103416:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103419:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = dev;
8010341e:	8b 45 08             	mov    0x8(%ebp),%eax
80103421:	a3 c4 32 11 80       	mov    %eax,0x801132c4
  recover_from_log();
80103426:	e8 b2 01 00 00       	call   801035dd <recover_from_log>
}
8010342b:	90                   	nop
8010342c:	c9                   	leave  
8010342d:	c3                   	ret    

8010342e <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010342e:	55                   	push   %ebp
8010342f:	89 e5                	mov    %esp,%ebp
80103431:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103434:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010343b:	e9 95 00 00 00       	jmp    801034d5 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103440:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103449:	01 d0                	add    %edx,%eax
8010344b:	83 c0 01             	add    $0x1,%eax
8010344e:	89 c2                	mov    %eax,%edx
80103450:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103455:	83 ec 08             	sub    $0x8,%esp
80103458:	52                   	push   %edx
80103459:	50                   	push   %eax
8010345a:	e8 57 cd ff ff       	call   801001b6 <bread>
8010345f:	83 c4 10             	add    $0x10,%esp
80103462:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103468:	83 c0 10             	add    $0x10,%eax
8010346b:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103472:	89 c2                	mov    %eax,%edx
80103474:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103479:	83 ec 08             	sub    $0x8,%esp
8010347c:	52                   	push   %edx
8010347d:	50                   	push   %eax
8010347e:	e8 33 cd ff ff       	call   801001b6 <bread>
80103483:	83 c4 10             	add    $0x10,%esp
80103486:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010348c:	8d 50 18             	lea    0x18(%eax),%edx
8010348f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103492:	83 c0 18             	add    $0x18,%eax
80103495:	83 ec 04             	sub    $0x4,%esp
80103498:	68 00 02 00 00       	push   $0x200
8010349d:	52                   	push   %edx
8010349e:	50                   	push   %eax
8010349f:	e8 32 2b 00 00       	call   80105fd6 <memmove>
801034a4:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801034a7:	83 ec 0c             	sub    $0xc,%esp
801034aa:	ff 75 ec             	pushl  -0x14(%ebp)
801034ad:	e8 3d cd ff ff       	call   801001ef <bwrite>
801034b2:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801034b5:	83 ec 0c             	sub    $0xc,%esp
801034b8:	ff 75 f0             	pushl  -0x10(%ebp)
801034bb:	e8 6e cd ff ff       	call   8010022e <brelse>
801034c0:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801034c3:	83 ec 0c             	sub    $0xc,%esp
801034c6:	ff 75 ec             	pushl  -0x14(%ebp)
801034c9:	e8 60 cd ff ff       	call   8010022e <brelse>
801034ce:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034d1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034d5:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801034da:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034dd:	0f 8f 5d ff ff ff    	jg     80103440 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
801034e3:	90                   	nop
801034e4:	c9                   	leave  
801034e5:	c3                   	ret    

801034e6 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801034e6:	55                   	push   %ebp
801034e7:	89 e5                	mov    %esp,%ebp
801034e9:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ec:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801034f1:	89 c2                	mov    %eax,%edx
801034f3:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801034f8:	83 ec 08             	sub    $0x8,%esp
801034fb:	52                   	push   %edx
801034fc:	50                   	push   %eax
801034fd:	e8 b4 cc ff ff       	call   801001b6 <bread>
80103502:	83 c4 10             	add    $0x10,%esp
80103505:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103508:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010350b:	83 c0 18             	add    $0x18,%eax
8010350e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103511:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103514:	8b 00                	mov    (%eax),%eax
80103516:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
8010351b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103522:	eb 1b                	jmp    8010353f <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103524:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103527:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010352a:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010352e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103531:	83 c2 10             	add    $0x10,%edx
80103534:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010353b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010353f:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103544:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103547:	7f db                	jg     80103524 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103549:	83 ec 0c             	sub    $0xc,%esp
8010354c:	ff 75 f0             	pushl  -0x10(%ebp)
8010354f:	e8 da cc ff ff       	call   8010022e <brelse>
80103554:	83 c4 10             	add    $0x10,%esp
}
80103557:	90                   	nop
80103558:	c9                   	leave  
80103559:	c3                   	ret    

8010355a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010355a:	55                   	push   %ebp
8010355b:	89 e5                	mov    %esp,%ebp
8010355d:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103560:	a1 b4 32 11 80       	mov    0x801132b4,%eax
80103565:	89 c2                	mov    %eax,%edx
80103567:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010356c:	83 ec 08             	sub    $0x8,%esp
8010356f:	52                   	push   %edx
80103570:	50                   	push   %eax
80103571:	e8 40 cc ff ff       	call   801001b6 <bread>
80103576:	83 c4 10             	add    $0x10,%esp
80103579:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
8010357c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010357f:	83 c0 18             	add    $0x18,%eax
80103582:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103585:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
8010358b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010358e:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103590:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103597:	eb 1b                	jmp    801035b4 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103599:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010359c:	83 c0 10             	add    $0x10,%eax
8010359f:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
801035a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035ac:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801035b0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801035b4:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801035b9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035bc:	7f db                	jg     80103599 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801035be:	83 ec 0c             	sub    $0xc,%esp
801035c1:	ff 75 f0             	pushl  -0x10(%ebp)
801035c4:	e8 26 cc ff ff       	call   801001ef <bwrite>
801035c9:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801035cc:	83 ec 0c             	sub    $0xc,%esp
801035cf:	ff 75 f0             	pushl  -0x10(%ebp)
801035d2:	e8 57 cc ff ff       	call   8010022e <brelse>
801035d7:	83 c4 10             	add    $0x10,%esp
}
801035da:	90                   	nop
801035db:	c9                   	leave  
801035dc:	c3                   	ret    

801035dd <recover_from_log>:

static void
recover_from_log(void)
{
801035dd:	55                   	push   %ebp
801035de:	89 e5                	mov    %esp,%ebp
801035e0:	83 ec 08             	sub    $0x8,%esp
  read_head();      
801035e3:	e8 fe fe ff ff       	call   801034e6 <read_head>
  install_trans(); // if committed, copy from log to disk
801035e8:	e8 41 fe ff ff       	call   8010342e <install_trans>
  log.lh.n = 0;
801035ed:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801035f4:	00 00 00 
  write_head(); // clear the log
801035f7:	e8 5e ff ff ff       	call   8010355a <write_head>
}
801035fc:	90                   	nop
801035fd:	c9                   	leave  
801035fe:	c3                   	ret    

801035ff <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801035ff:	55                   	push   %ebp
80103600:	89 e5                	mov    %esp,%ebp
80103602:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103605:	83 ec 0c             	sub    $0xc,%esp
80103608:	68 80 32 11 80       	push   $0x80113280
8010360d:	e8 a2 26 00 00       	call   80105cb4 <acquire>
80103612:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103615:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010361a:	85 c0                	test   %eax,%eax
8010361c:	74 17                	je     80103635 <begin_op+0x36>
      sleep(&log, &log.lock);
8010361e:	83 ec 08             	sub    $0x8,%esp
80103621:	68 80 32 11 80       	push   $0x80113280
80103626:	68 80 32 11 80       	push   $0x80113280
8010362b:	e8 d9 18 00 00       	call   80104f09 <sleep>
80103630:	83 c4 10             	add    $0x10,%esp
80103633:	eb e0                	jmp    80103615 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103635:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
8010363b:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103640:	8d 50 01             	lea    0x1(%eax),%edx
80103643:	89 d0                	mov    %edx,%eax
80103645:	c1 e0 02             	shl    $0x2,%eax
80103648:	01 d0                	add    %edx,%eax
8010364a:	01 c0                	add    %eax,%eax
8010364c:	01 c8                	add    %ecx,%eax
8010364e:	83 f8 1e             	cmp    $0x1e,%eax
80103651:	7e 17                	jle    8010366a <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103653:	83 ec 08             	sub    $0x8,%esp
80103656:	68 80 32 11 80       	push   $0x80113280
8010365b:	68 80 32 11 80       	push   $0x80113280
80103660:	e8 a4 18 00 00       	call   80104f09 <sleep>
80103665:	83 c4 10             	add    $0x10,%esp
80103668:	eb ab                	jmp    80103615 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010366a:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010366f:	83 c0 01             	add    $0x1,%eax
80103672:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
80103677:	83 ec 0c             	sub    $0xc,%esp
8010367a:	68 80 32 11 80       	push   $0x80113280
8010367f:	e8 97 26 00 00       	call   80105d1b <release>
80103684:	83 c4 10             	add    $0x10,%esp
      break;
80103687:	90                   	nop
    }
  }
}
80103688:	90                   	nop
80103689:	c9                   	leave  
8010368a:	c3                   	ret    

8010368b <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010368b:	55                   	push   %ebp
8010368c:	89 e5                	mov    %esp,%ebp
8010368e:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103698:	83 ec 0c             	sub    $0xc,%esp
8010369b:	68 80 32 11 80       	push   $0x80113280
801036a0:	e8 0f 26 00 00       	call   80105cb4 <acquire>
801036a5:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801036a8:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036ad:	83 e8 01             	sub    $0x1,%eax
801036b0:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
801036b5:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801036ba:	85 c0                	test   %eax,%eax
801036bc:	74 0d                	je     801036cb <end_op+0x40>
    panic("log.committing");
801036be:	83 ec 0c             	sub    $0xc,%esp
801036c1:	68 b8 95 10 80       	push   $0x801095b8
801036c6:	e8 9b ce ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801036cb:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801036d0:	85 c0                	test   %eax,%eax
801036d2:	75 13                	jne    801036e7 <end_op+0x5c>
    do_commit = 1;
801036d4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801036db:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
801036e2:	00 00 00 
801036e5:	eb 10                	jmp    801036f7 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
801036e7:	83 ec 0c             	sub    $0xc,%esp
801036ea:	68 80 32 11 80       	push   $0x80113280
801036ef:	e8 2a 19 00 00       	call   8010501e <wakeup>
801036f4:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801036f7:	83 ec 0c             	sub    $0xc,%esp
801036fa:	68 80 32 11 80       	push   $0x80113280
801036ff:	e8 17 26 00 00       	call   80105d1b <release>
80103704:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103707:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010370b:	74 3f                	je     8010374c <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010370d:	e8 f5 00 00 00       	call   80103807 <commit>
    acquire(&log.lock);
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	68 80 32 11 80       	push   $0x80113280
8010371a:	e8 95 25 00 00       	call   80105cb4 <acquire>
8010371f:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103722:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103729:	00 00 00 
    wakeup(&log);
8010372c:	83 ec 0c             	sub    $0xc,%esp
8010372f:	68 80 32 11 80       	push   $0x80113280
80103734:	e8 e5 18 00 00       	call   8010501e <wakeup>
80103739:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010373c:	83 ec 0c             	sub    $0xc,%esp
8010373f:	68 80 32 11 80       	push   $0x80113280
80103744:	e8 d2 25 00 00       	call   80105d1b <release>
80103749:	83 c4 10             	add    $0x10,%esp
  }
}
8010374c:	90                   	nop
8010374d:	c9                   	leave  
8010374e:	c3                   	ret    

8010374f <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010374f:	55                   	push   %ebp
80103750:	89 e5                	mov    %esp,%ebp
80103752:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103755:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010375c:	e9 95 00 00 00       	jmp    801037f6 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103761:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010376a:	01 d0                	add    %edx,%eax
8010376c:	83 c0 01             	add    $0x1,%eax
8010376f:	89 c2                	mov    %eax,%edx
80103771:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103776:	83 ec 08             	sub    $0x8,%esp
80103779:	52                   	push   %edx
8010377a:	50                   	push   %eax
8010377b:	e8 36 ca ff ff       	call   801001b6 <bread>
80103780:	83 c4 10             	add    $0x10,%esp
80103783:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103789:	83 c0 10             	add    $0x10,%eax
8010378c:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103793:	89 c2                	mov    %eax,%edx
80103795:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010379a:	83 ec 08             	sub    $0x8,%esp
8010379d:	52                   	push   %edx
8010379e:	50                   	push   %eax
8010379f:	e8 12 ca ff ff       	call   801001b6 <bread>
801037a4:	83 c4 10             	add    $0x10,%esp
801037a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801037aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037ad:	8d 50 18             	lea    0x18(%eax),%edx
801037b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037b3:	83 c0 18             	add    $0x18,%eax
801037b6:	83 ec 04             	sub    $0x4,%esp
801037b9:	68 00 02 00 00       	push   $0x200
801037be:	52                   	push   %edx
801037bf:	50                   	push   %eax
801037c0:	e8 11 28 00 00       	call   80105fd6 <memmove>
801037c5:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801037c8:	83 ec 0c             	sub    $0xc,%esp
801037cb:	ff 75 f0             	pushl  -0x10(%ebp)
801037ce:	e8 1c ca ff ff       	call   801001ef <bwrite>
801037d3:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
801037d6:	83 ec 0c             	sub    $0xc,%esp
801037d9:	ff 75 ec             	pushl  -0x14(%ebp)
801037dc:	e8 4d ca ff ff       	call   8010022e <brelse>
801037e1:	83 c4 10             	add    $0x10,%esp
    brelse(to);
801037e4:	83 ec 0c             	sub    $0xc,%esp
801037e7:	ff 75 f0             	pushl  -0x10(%ebp)
801037ea:	e8 3f ca ff ff       	call   8010022e <brelse>
801037ef:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037f6:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801037fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037fe:	0f 8f 5d ff ff ff    	jg     80103761 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103804:	90                   	nop
80103805:	c9                   	leave  
80103806:	c3                   	ret    

80103807 <commit>:

static void
commit()
{
80103807:	55                   	push   %ebp
80103808:	89 e5                	mov    %esp,%ebp
8010380a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010380d:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103812:	85 c0                	test   %eax,%eax
80103814:	7e 1e                	jle    80103834 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103816:	e8 34 ff ff ff       	call   8010374f <write_log>
    write_head();    // Write header to disk -- the real commit
8010381b:	e8 3a fd ff ff       	call   8010355a <write_head>
    install_trans(); // Now install writes to home locations
80103820:	e8 09 fc ff ff       	call   8010342e <install_trans>
    log.lh.n = 0; 
80103825:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
8010382c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010382f:	e8 26 fd ff ff       	call   8010355a <write_head>
  }
}
80103834:	90                   	nop
80103835:	c9                   	leave  
80103836:	c3                   	ret    

80103837 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103837:	55                   	push   %ebp
80103838:	89 e5                	mov    %esp,%ebp
8010383a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010383d:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103842:	83 f8 1d             	cmp    $0x1d,%eax
80103845:	7f 12                	jg     80103859 <log_write+0x22>
80103847:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010384c:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103852:	83 ea 01             	sub    $0x1,%edx
80103855:	39 d0                	cmp    %edx,%eax
80103857:	7c 0d                	jl     80103866 <log_write+0x2f>
    panic("too big a transaction");
80103859:	83 ec 0c             	sub    $0xc,%esp
8010385c:	68 c7 95 10 80       	push   $0x801095c7
80103861:	e8 00 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103866:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010386b:	85 c0                	test   %eax,%eax
8010386d:	7f 0d                	jg     8010387c <log_write+0x45>
    panic("log_write outside of trans");
8010386f:	83 ec 0c             	sub    $0xc,%esp
80103872:	68 dd 95 10 80       	push   $0x801095dd
80103877:	e8 ea cc ff ff       	call   80100566 <panic>

  acquire(&log.lock);
8010387c:	83 ec 0c             	sub    $0xc,%esp
8010387f:	68 80 32 11 80       	push   $0x80113280
80103884:	e8 2b 24 00 00       	call   80105cb4 <acquire>
80103889:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
8010388c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103893:	eb 1d                	jmp    801038b2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103898:	83 c0 10             	add    $0x10,%eax
8010389b:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801038a2:	89 c2                	mov    %eax,%edx
801038a4:	8b 45 08             	mov    0x8(%ebp),%eax
801038a7:	8b 40 08             	mov    0x8(%eax),%eax
801038aa:	39 c2                	cmp    %eax,%edx
801038ac:	74 10                	je     801038be <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801038ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801038b2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ba:	7f d9                	jg     80103895 <log_write+0x5e>
801038bc:	eb 01                	jmp    801038bf <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801038be:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801038bf:	8b 45 08             	mov    0x8(%ebp),%eax
801038c2:	8b 40 08             	mov    0x8(%eax),%eax
801038c5:	89 c2                	mov    %eax,%edx
801038c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ca:	83 c0 10             	add    $0x10,%eax
801038cd:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
801038d4:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038d9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038dc:	75 0d                	jne    801038eb <log_write+0xb4>
    log.lh.n++;
801038de:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801038e3:	83 c0 01             	add    $0x1,%eax
801038e6:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801038eb:	8b 45 08             	mov    0x8(%ebp),%eax
801038ee:	8b 00                	mov    (%eax),%eax
801038f0:	83 c8 04             	or     $0x4,%eax
801038f3:	89 c2                	mov    %eax,%edx
801038f5:	8b 45 08             	mov    0x8(%ebp),%eax
801038f8:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801038fa:	83 ec 0c             	sub    $0xc,%esp
801038fd:	68 80 32 11 80       	push   $0x80113280
80103902:	e8 14 24 00 00       	call   80105d1b <release>
80103907:	83 c4 10             	add    $0x10,%esp
}
8010390a:	90                   	nop
8010390b:	c9                   	leave  
8010390c:	c3                   	ret    

8010390d <v2p>:
8010390d:	55                   	push   %ebp
8010390e:	89 e5                	mov    %esp,%ebp
80103910:	8b 45 08             	mov    0x8(%ebp),%eax
80103913:	05 00 00 00 80       	add    $0x80000000,%eax
80103918:	5d                   	pop    %ebp
80103919:	c3                   	ret    

8010391a <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010391a:	55                   	push   %ebp
8010391b:	89 e5                	mov    %esp,%ebp
8010391d:	8b 45 08             	mov    0x8(%ebp),%eax
80103920:	05 00 00 00 80       	add    $0x80000000,%eax
80103925:	5d                   	pop    %ebp
80103926:	c3                   	ret    

80103927 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103927:	55                   	push   %ebp
80103928:	89 e5                	mov    %esp,%ebp
8010392a:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010392d:	8b 55 08             	mov    0x8(%ebp),%edx
80103930:	8b 45 0c             	mov    0xc(%ebp),%eax
80103933:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103936:	f0 87 02             	lock xchg %eax,(%edx)
80103939:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010393c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010393f:	c9                   	leave  
80103940:	c3                   	ret    

80103941 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103941:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103945:	83 e4 f0             	and    $0xfffffff0,%esp
80103948:	ff 71 fc             	pushl  -0x4(%ecx)
8010394b:	55                   	push   %ebp
8010394c:	89 e5                	mov    %esp,%ebp
8010394e:	51                   	push   %ecx
8010394f:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103952:	83 ec 08             	sub    $0x8,%esp
80103955:	68 00 00 40 80       	push   $0x80400000
8010395a:	68 5c 67 11 80       	push   $0x8011675c
8010395f:	e8 7d f2 ff ff       	call   80102be1 <kinit1>
80103964:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103967:	e8 5b 52 00 00       	call   80108bc7 <kvmalloc>
  mpinit();        // collect info about this machine
8010396c:	e8 43 04 00 00       	call   80103db4 <mpinit>
  lapicinit();
80103971:	e8 ea f5 ff ff       	call   80102f60 <lapicinit>
  seginit();       // set up segments
80103976:	e8 f5 4b 00 00       	call   80108570 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
8010397b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103981:	0f b6 00             	movzbl (%eax),%eax
80103984:	0f b6 c0             	movzbl %al,%eax
80103987:	83 ec 08             	sub    $0x8,%esp
8010398a:	50                   	push   %eax
8010398b:	68 f8 95 10 80       	push   $0x801095f8
80103990:	e8 31 ca ff ff       	call   801003c6 <cprintf>
80103995:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103998:	e8 6d 06 00 00       	call   8010400a <picinit>
  ioapicinit();    // another interrupt controller
8010399d:	e8 34 f1 ff ff       	call   80102ad6 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801039a2:	e8 24 d2 ff ff       	call   80100bcb <consoleinit>
  uartinit();      // serial port
801039a7:	e8 20 3f 00 00       	call   801078cc <uartinit>
  pinit();         // process table
801039ac:	e8 5d 0b 00 00       	call   8010450e <pinit>
  tvinit();        // trap vectors
801039b1:	e8 ef 3a 00 00       	call   801074a5 <tvinit>
  binit();         // buffer cache
801039b6:	e8 79 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039bb:	e8 67 d6 ff ff       	call   80101027 <fileinit>
  ideinit();       // disk
801039c0:	e8 19 ed ff ff       	call   801026de <ideinit>
  if(!ismp)
801039c5:	a1 64 33 11 80       	mov    0x80113364,%eax
801039ca:	85 c0                	test   %eax,%eax
801039cc:	75 05                	jne    801039d3 <main+0x92>
    timerinit();   // uniprocessor timer
801039ce:	e8 23 3a 00 00       	call   801073f6 <timerinit>
  startothers();   // start other processors
801039d3:	e8 7f 00 00 00       	call   80103a57 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039d8:	83 ec 08             	sub    $0x8,%esp
801039db:	68 00 00 00 8e       	push   $0x8e000000
801039e0:	68 00 00 40 80       	push   $0x80400000
801039e5:	e8 30 f2 ff ff       	call   80102c1a <kinit2>
801039ea:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801039ed:	e8 69 0c 00 00       	call   8010465b <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801039f2:	e8 1a 00 00 00       	call   80103a11 <mpmain>

801039f7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039f7:	55                   	push   %ebp
801039f8:	89 e5                	mov    %esp,%ebp
801039fa:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
801039fd:	e8 dd 51 00 00       	call   80108bdf <switchkvm>
  seginit();
80103a02:	e8 69 4b 00 00       	call   80108570 <seginit>
  lapicinit();
80103a07:	e8 54 f5 ff ff       	call   80102f60 <lapicinit>
  mpmain();
80103a0c:	e8 00 00 00 00       	call   80103a11 <mpmain>

80103a11 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a11:	55                   	push   %ebp
80103a12:	89 e5                	mov    %esp,%ebp
80103a14:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103a17:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a1d:	0f b6 00             	movzbl (%eax),%eax
80103a20:	0f b6 c0             	movzbl %al,%eax
80103a23:	83 ec 08             	sub    $0x8,%esp
80103a26:	50                   	push   %eax
80103a27:	68 0f 96 10 80       	push   $0x8010960f
80103a2c:	e8 95 c9 ff ff       	call   801003c6 <cprintf>
80103a31:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103a34:	e8 cd 3b 00 00       	call   80107606 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103a39:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103a3f:	05 a8 00 00 00       	add    $0xa8,%eax
80103a44:	83 ec 08             	sub    $0x8,%esp
80103a47:	6a 01                	push   $0x1
80103a49:	50                   	push   %eax
80103a4a:	e8 d8 fe ff ff       	call   80103927 <xchg>
80103a4f:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103a52:	e8 6e 12 00 00       	call   80104cc5 <scheduler>

80103a57 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a57:	55                   	push   %ebp
80103a58:	89 e5                	mov    %esp,%ebp
80103a5a:	53                   	push   %ebx
80103a5b:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103a5e:	68 00 70 00 00       	push   $0x7000
80103a63:	e8 b2 fe ff ff       	call   8010391a <p2v>
80103a68:	83 c4 04             	add    $0x4,%esp
80103a6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a6e:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a73:	83 ec 04             	sub    $0x4,%esp
80103a76:	50                   	push   %eax
80103a77:	68 2c c5 10 80       	push   $0x8010c52c
80103a7c:	ff 75 f0             	pushl  -0x10(%ebp)
80103a7f:	e8 52 25 00 00       	call   80105fd6 <memmove>
80103a84:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103a87:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
80103a8e:	e9 90 00 00 00       	jmp    80103b23 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103a93:	e8 e6 f5 ff ff       	call   8010307e <cpunum>
80103a98:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a9e:	05 80 33 11 80       	add    $0x80113380,%eax
80103aa3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aa6:	74 73                	je     80103b1b <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103aa8:	e8 6b f2 ff ff       	call   80102d18 <kalloc>
80103aad:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103ab0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ab3:	83 e8 04             	sub    $0x4,%eax
80103ab6:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103ab9:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103abf:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac4:	83 e8 08             	sub    $0x8,%eax
80103ac7:	c7 00 f7 39 10 80    	movl   $0x801039f7,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad0:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103ad3:	83 ec 0c             	sub    $0xc,%esp
80103ad6:	68 00 b0 10 80       	push   $0x8010b000
80103adb:	e8 2d fe ff ff       	call   8010390d <v2p>
80103ae0:	83 c4 10             	add    $0x10,%esp
80103ae3:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103ae5:	83 ec 0c             	sub    $0xc,%esp
80103ae8:	ff 75 f0             	pushl  -0x10(%ebp)
80103aeb:	e8 1d fe ff ff       	call   8010390d <v2p>
80103af0:	83 c4 10             	add    $0x10,%esp
80103af3:	89 c2                	mov    %eax,%edx
80103af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af8:	0f b6 00             	movzbl (%eax),%eax
80103afb:	0f b6 c0             	movzbl %al,%eax
80103afe:	83 ec 08             	sub    $0x8,%esp
80103b01:	52                   	push   %edx
80103b02:	50                   	push   %eax
80103b03:	e8 f0 f5 ff ff       	call   801030f8 <lapicstartap>
80103b08:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b0b:	90                   	nop
80103b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103b15:	85 c0                	test   %eax,%eax
80103b17:	74 f3                	je     80103b0c <startothers+0xb5>
80103b19:	eb 01                	jmp    80103b1c <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103b1b:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b1c:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103b23:	a1 60 39 11 80       	mov    0x80113960,%eax
80103b28:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103b2e:	05 80 33 11 80       	add    $0x80113380,%eax
80103b33:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b36:	0f 87 57 ff ff ff    	ja     80103a93 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b3c:	90                   	nop
80103b3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b40:	c9                   	leave  
80103b41:	c3                   	ret    

80103b42 <p2v>:
80103b42:	55                   	push   %ebp
80103b43:	89 e5                	mov    %esp,%ebp
80103b45:	8b 45 08             	mov    0x8(%ebp),%eax
80103b48:	05 00 00 00 80       	add    $0x80000000,%eax
80103b4d:	5d                   	pop    %ebp
80103b4e:	c3                   	ret    

80103b4f <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103b4f:	55                   	push   %ebp
80103b50:	89 e5                	mov    %esp,%ebp
80103b52:	83 ec 14             	sub    $0x14,%esp
80103b55:	8b 45 08             	mov    0x8(%ebp),%eax
80103b58:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b5c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103b60:	89 c2                	mov    %eax,%edx
80103b62:	ec                   	in     (%dx),%al
80103b63:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b66:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103b6a:	c9                   	leave  
80103b6b:	c3                   	ret    

80103b6c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b6c:	55                   	push   %ebp
80103b6d:	89 e5                	mov    %esp,%ebp
80103b6f:	83 ec 08             	sub    $0x8,%esp
80103b72:	8b 55 08             	mov    0x8(%ebp),%edx
80103b75:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b78:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103b7c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b7f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103b83:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103b87:	ee                   	out    %al,(%dx)
}
80103b88:	90                   	nop
80103b89:	c9                   	leave  
80103b8a:	c3                   	ret    

80103b8b <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b8b:	55                   	push   %ebp
80103b8c:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b8e:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103b93:	89 c2                	mov    %eax,%edx
80103b95:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103b9a:	29 c2                	sub    %eax,%edx
80103b9c:	89 d0                	mov    %edx,%eax
80103b9e:	c1 f8 02             	sar    $0x2,%eax
80103ba1:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103ba7:	5d                   	pop    %ebp
80103ba8:	c3                   	ret    

80103ba9 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103ba9:	55                   	push   %ebp
80103baa:	89 e5                	mov    %esp,%ebp
80103bac:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103baf:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103bb6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103bbd:	eb 15                	jmp    80103bd4 <sum+0x2b>
    sum += addr[i];
80103bbf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80103bc5:	01 d0                	add    %edx,%eax
80103bc7:	0f b6 00             	movzbl (%eax),%eax
80103bca:	0f b6 c0             	movzbl %al,%eax
80103bcd:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103bd0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103bd4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103bd7:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103bda:	7c e3                	jl     80103bbf <sum+0x16>
    sum += addr[i];
  return sum;
80103bdc:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103bdf:	c9                   	leave  
80103be0:	c3                   	ret    

80103be1 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103be1:	55                   	push   %ebp
80103be2:	89 e5                	mov    %esp,%ebp
80103be4:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103be7:	ff 75 08             	pushl  0x8(%ebp)
80103bea:	e8 53 ff ff ff       	call   80103b42 <p2v>
80103bef:	83 c4 04             	add    $0x4,%esp
80103bf2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103bf5:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bfb:	01 d0                	add    %edx,%eax
80103bfd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c06:	eb 36                	jmp    80103c3e <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c08:	83 ec 04             	sub    $0x4,%esp
80103c0b:	6a 04                	push   $0x4
80103c0d:	68 20 96 10 80       	push   $0x80109620
80103c12:	ff 75 f4             	pushl  -0xc(%ebp)
80103c15:	e8 64 23 00 00       	call   80105f7e <memcmp>
80103c1a:	83 c4 10             	add    $0x10,%esp
80103c1d:	85 c0                	test   %eax,%eax
80103c1f:	75 19                	jne    80103c3a <mpsearch1+0x59>
80103c21:	83 ec 08             	sub    $0x8,%esp
80103c24:	6a 10                	push   $0x10
80103c26:	ff 75 f4             	pushl  -0xc(%ebp)
80103c29:	e8 7b ff ff ff       	call   80103ba9 <sum>
80103c2e:	83 c4 10             	add    $0x10,%esp
80103c31:	84 c0                	test   %al,%al
80103c33:	75 05                	jne    80103c3a <mpsearch1+0x59>
      return (struct mp*)p;
80103c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c38:	eb 11                	jmp    80103c4b <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c3a:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c41:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c44:	72 c2                	jb     80103c08 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c46:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c4b:	c9                   	leave  
80103c4c:	c3                   	ret    

80103c4d <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c4d:	55                   	push   %ebp
80103c4e:	89 e5                	mov    %esp,%ebp
80103c50:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c53:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5d:	83 c0 0f             	add    $0xf,%eax
80103c60:	0f b6 00             	movzbl (%eax),%eax
80103c63:	0f b6 c0             	movzbl %al,%eax
80103c66:	c1 e0 08             	shl    $0x8,%eax
80103c69:	89 c2                	mov    %eax,%edx
80103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6e:	83 c0 0e             	add    $0xe,%eax
80103c71:	0f b6 00             	movzbl (%eax),%eax
80103c74:	0f b6 c0             	movzbl %al,%eax
80103c77:	09 d0                	or     %edx,%eax
80103c79:	c1 e0 04             	shl    $0x4,%eax
80103c7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c83:	74 21                	je     80103ca6 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103c85:	83 ec 08             	sub    $0x8,%esp
80103c88:	68 00 04 00 00       	push   $0x400
80103c8d:	ff 75 f0             	pushl  -0x10(%ebp)
80103c90:	e8 4c ff ff ff       	call   80103be1 <mpsearch1>
80103c95:	83 c4 10             	add    $0x10,%esp
80103c98:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c9f:	74 51                	je     80103cf2 <mpsearch+0xa5>
      return mp;
80103ca1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ca4:	eb 61                	jmp    80103d07 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca9:	83 c0 14             	add    $0x14,%eax
80103cac:	0f b6 00             	movzbl (%eax),%eax
80103caf:	0f b6 c0             	movzbl %al,%eax
80103cb2:	c1 e0 08             	shl    $0x8,%eax
80103cb5:	89 c2                	mov    %eax,%edx
80103cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cba:	83 c0 13             	add    $0x13,%eax
80103cbd:	0f b6 00             	movzbl (%eax),%eax
80103cc0:	0f b6 c0             	movzbl %al,%eax
80103cc3:	09 d0                	or     %edx,%eax
80103cc5:	c1 e0 0a             	shl    $0xa,%eax
80103cc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cce:	2d 00 04 00 00       	sub    $0x400,%eax
80103cd3:	83 ec 08             	sub    $0x8,%esp
80103cd6:	68 00 04 00 00       	push   $0x400
80103cdb:	50                   	push   %eax
80103cdc:	e8 00 ff ff ff       	call   80103be1 <mpsearch1>
80103ce1:	83 c4 10             	add    $0x10,%esp
80103ce4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ce7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ceb:	74 05                	je     80103cf2 <mpsearch+0xa5>
      return mp;
80103ced:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cf0:	eb 15                	jmp    80103d07 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103cf2:	83 ec 08             	sub    $0x8,%esp
80103cf5:	68 00 00 01 00       	push   $0x10000
80103cfa:	68 00 00 0f 00       	push   $0xf0000
80103cff:	e8 dd fe ff ff       	call   80103be1 <mpsearch1>
80103d04:	83 c4 10             	add    $0x10,%esp
}
80103d07:	c9                   	leave  
80103d08:	c3                   	ret    

80103d09 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d09:	55                   	push   %ebp
80103d0a:	89 e5                	mov    %esp,%ebp
80103d0c:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d0f:	e8 39 ff ff ff       	call   80103c4d <mpsearch>
80103d14:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d17:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d1b:	74 0a                	je     80103d27 <mpconfig+0x1e>
80103d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d20:	8b 40 04             	mov    0x4(%eax),%eax
80103d23:	85 c0                	test   %eax,%eax
80103d25:	75 0a                	jne    80103d31 <mpconfig+0x28>
    return 0;
80103d27:	b8 00 00 00 00       	mov    $0x0,%eax
80103d2c:	e9 81 00 00 00       	jmp    80103db2 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103d31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d34:	8b 40 04             	mov    0x4(%eax),%eax
80103d37:	83 ec 0c             	sub    $0xc,%esp
80103d3a:	50                   	push   %eax
80103d3b:	e8 02 fe ff ff       	call   80103b42 <p2v>
80103d40:	83 c4 10             	add    $0x10,%esp
80103d43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d46:	83 ec 04             	sub    $0x4,%esp
80103d49:	6a 04                	push   $0x4
80103d4b:	68 25 96 10 80       	push   $0x80109625
80103d50:	ff 75 f0             	pushl  -0x10(%ebp)
80103d53:	e8 26 22 00 00       	call   80105f7e <memcmp>
80103d58:	83 c4 10             	add    $0x10,%esp
80103d5b:	85 c0                	test   %eax,%eax
80103d5d:	74 07                	je     80103d66 <mpconfig+0x5d>
    return 0;
80103d5f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d64:	eb 4c                	jmp    80103db2 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d69:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d6d:	3c 01                	cmp    $0x1,%al
80103d6f:	74 12                	je     80103d83 <mpconfig+0x7a>
80103d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d74:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103d78:	3c 04                	cmp    $0x4,%al
80103d7a:	74 07                	je     80103d83 <mpconfig+0x7a>
    return 0;
80103d7c:	b8 00 00 00 00       	mov    $0x0,%eax
80103d81:	eb 2f                	jmp    80103db2 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d86:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d8a:	0f b7 c0             	movzwl %ax,%eax
80103d8d:	83 ec 08             	sub    $0x8,%esp
80103d90:	50                   	push   %eax
80103d91:	ff 75 f0             	pushl  -0x10(%ebp)
80103d94:	e8 10 fe ff ff       	call   80103ba9 <sum>
80103d99:	83 c4 10             	add    $0x10,%esp
80103d9c:	84 c0                	test   %al,%al
80103d9e:	74 07                	je     80103da7 <mpconfig+0x9e>
    return 0;
80103da0:	b8 00 00 00 00       	mov    $0x0,%eax
80103da5:	eb 0b                	jmp    80103db2 <mpconfig+0xa9>
  *pmp = mp;
80103da7:	8b 45 08             	mov    0x8(%ebp),%eax
80103daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dad:	89 10                	mov    %edx,(%eax)
  return conf;
80103daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103db2:	c9                   	leave  
80103db3:	c3                   	ret    

80103db4 <mpinit>:

void
mpinit(void)
{
80103db4:	55                   	push   %ebp
80103db5:	89 e5                	mov    %esp,%ebp
80103db7:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103dba:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103dc1:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103dc4:	83 ec 0c             	sub    $0xc,%esp
80103dc7:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103dca:	50                   	push   %eax
80103dcb:	e8 39 ff ff ff       	call   80103d09 <mpconfig>
80103dd0:	83 c4 10             	add    $0x10,%esp
80103dd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103dd6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dda:	0f 84 96 01 00 00    	je     80103f76 <mpinit+0x1c2>
    return;
  ismp = 1;
80103de0:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103de7:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ded:	8b 40 24             	mov    0x24(%eax),%eax
80103df0:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df8:	83 c0 2c             	add    $0x2c,%eax
80103dfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e01:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103e05:	0f b7 d0             	movzwl %ax,%edx
80103e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e0b:	01 d0                	add    %edx,%eax
80103e0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e10:	e9 f2 00 00 00       	jmp    80103f07 <mpinit+0x153>
    switch(*p){
80103e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e18:	0f b6 00             	movzbl (%eax),%eax
80103e1b:	0f b6 c0             	movzbl %al,%eax
80103e1e:	83 f8 04             	cmp    $0x4,%eax
80103e21:	0f 87 bc 00 00 00    	ja     80103ee3 <mpinit+0x12f>
80103e27:	8b 04 85 68 96 10 80 	mov    -0x7fef6998(,%eax,4),%eax
80103e2e:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e33:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103e36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e39:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e3d:	0f b6 d0             	movzbl %al,%edx
80103e40:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e45:	39 c2                	cmp    %eax,%edx
80103e47:	74 2b                	je     80103e74 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103e49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e4c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e50:	0f b6 d0             	movzbl %al,%edx
80103e53:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e58:	83 ec 04             	sub    $0x4,%esp
80103e5b:	52                   	push   %edx
80103e5c:	50                   	push   %eax
80103e5d:	68 2a 96 10 80       	push   $0x8010962a
80103e62:	e8 5f c5 ff ff       	call   801003c6 <cprintf>
80103e67:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103e6a:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103e71:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e74:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e77:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e7b:	0f b6 c0             	movzbl %al,%eax
80103e7e:	83 e0 02             	and    $0x2,%eax
80103e81:	85 c0                	test   %eax,%eax
80103e83:	74 15                	je     80103e9a <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103e85:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e8a:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e90:	05 80 33 11 80       	add    $0x80113380,%eax
80103e95:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103e9a:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e9f:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103ea5:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103eab:	05 80 33 11 80       	add    $0x80113380,%eax
80103eb0:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103eb2:	a1 60 39 11 80       	mov    0x80113960,%eax
80103eb7:	83 c0 01             	add    $0x1,%eax
80103eba:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103ebf:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103ec3:	eb 42                	jmp    80103f07 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ec8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103ecb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ece:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103ed2:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103ed7:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103edb:	eb 2a                	jmp    80103f07 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103edd:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103ee1:	eb 24                	jmp    80103f07 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ee6:	0f b6 00             	movzbl (%eax),%eax
80103ee9:	0f b6 c0             	movzbl %al,%eax
80103eec:	83 ec 08             	sub    $0x8,%esp
80103eef:	50                   	push   %eax
80103ef0:	68 48 96 10 80       	push   $0x80109648
80103ef5:	e8 cc c4 ff ff       	call   801003c6 <cprintf>
80103efa:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103efd:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103f04:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103f0d:	0f 82 02 ff ff ff    	jb     80103e15 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103f13:	a1 64 33 11 80       	mov    0x80113364,%eax
80103f18:	85 c0                	test   %eax,%eax
80103f1a:	75 1d                	jne    80103f39 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103f1c:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103f23:	00 00 00 
    lapic = 0;
80103f26:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103f2d:	00 00 00 
    ioapicid = 0;
80103f30:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103f37:	eb 3e                	jmp    80103f77 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103f39:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103f3c:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103f40:	84 c0                	test   %al,%al
80103f42:	74 33                	je     80103f77 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103f44:	83 ec 08             	sub    $0x8,%esp
80103f47:	6a 70                	push   $0x70
80103f49:	6a 22                	push   $0x22
80103f4b:	e8 1c fc ff ff       	call   80103b6c <outb>
80103f50:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103f53:	83 ec 0c             	sub    $0xc,%esp
80103f56:	6a 23                	push   $0x23
80103f58:	e8 f2 fb ff ff       	call   80103b4f <inb>
80103f5d:	83 c4 10             	add    $0x10,%esp
80103f60:	83 c8 01             	or     $0x1,%eax
80103f63:	0f b6 c0             	movzbl %al,%eax
80103f66:	83 ec 08             	sub    $0x8,%esp
80103f69:	50                   	push   %eax
80103f6a:	6a 23                	push   $0x23
80103f6c:	e8 fb fb ff ff       	call   80103b6c <outb>
80103f71:	83 c4 10             	add    $0x10,%esp
80103f74:	eb 01                	jmp    80103f77 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103f76:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103f77:	c9                   	leave  
80103f78:	c3                   	ret    

80103f79 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f79:	55                   	push   %ebp
80103f7a:	89 e5                	mov    %esp,%ebp
80103f7c:	83 ec 08             	sub    $0x8,%esp
80103f7f:	8b 55 08             	mov    0x8(%ebp),%edx
80103f82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f85:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103f89:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f8c:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f90:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f94:	ee                   	out    %al,(%dx)
}
80103f95:	90                   	nop
80103f96:	c9                   	leave  
80103f97:	c3                   	ret    

80103f98 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f98:	55                   	push   %ebp
80103f99:	89 e5                	mov    %esp,%ebp
80103f9b:	83 ec 04             	sub    $0x4,%esp
80103f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103fa5:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fa9:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103faf:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fb3:	0f b6 c0             	movzbl %al,%eax
80103fb6:	50                   	push   %eax
80103fb7:	6a 21                	push   $0x21
80103fb9:	e8 bb ff ff ff       	call   80103f79 <outb>
80103fbe:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103fc1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103fc5:	66 c1 e8 08          	shr    $0x8,%ax
80103fc9:	0f b6 c0             	movzbl %al,%eax
80103fcc:	50                   	push   %eax
80103fcd:	68 a1 00 00 00       	push   $0xa1
80103fd2:	e8 a2 ff ff ff       	call   80103f79 <outb>
80103fd7:	83 c4 08             	add    $0x8,%esp
}
80103fda:	90                   	nop
80103fdb:	c9                   	leave  
80103fdc:	c3                   	ret    

80103fdd <picenable>:

void
picenable(int irq)
{
80103fdd:	55                   	push   %ebp
80103fde:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103fe0:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe3:	ba 01 00 00 00       	mov    $0x1,%edx
80103fe8:	89 c1                	mov    %eax,%ecx
80103fea:	d3 e2                	shl    %cl,%edx
80103fec:	89 d0                	mov    %edx,%eax
80103fee:	f7 d0                	not    %eax
80103ff0:	89 c2                	mov    %eax,%edx
80103ff2:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103ff9:	21 d0                	and    %edx,%eax
80103ffb:	0f b7 c0             	movzwl %ax,%eax
80103ffe:	50                   	push   %eax
80103fff:	e8 94 ff ff ff       	call   80103f98 <picsetmask>
80104004:	83 c4 04             	add    $0x4,%esp
}
80104007:	90                   	nop
80104008:	c9                   	leave  
80104009:	c3                   	ret    

8010400a <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
8010400a:	55                   	push   %ebp
8010400b:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010400d:	68 ff 00 00 00       	push   $0xff
80104012:	6a 21                	push   $0x21
80104014:	e8 60 ff ff ff       	call   80103f79 <outb>
80104019:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
8010401c:	68 ff 00 00 00       	push   $0xff
80104021:	68 a1 00 00 00       	push   $0xa1
80104026:	e8 4e ff ff ff       	call   80103f79 <outb>
8010402b:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
8010402e:	6a 11                	push   $0x11
80104030:	6a 20                	push   $0x20
80104032:	e8 42 ff ff ff       	call   80103f79 <outb>
80104037:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
8010403a:	6a 20                	push   $0x20
8010403c:	6a 21                	push   $0x21
8010403e:	e8 36 ff ff ff       	call   80103f79 <outb>
80104043:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80104046:	6a 04                	push   $0x4
80104048:	6a 21                	push   $0x21
8010404a:	e8 2a ff ff ff       	call   80103f79 <outb>
8010404f:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80104052:	6a 03                	push   $0x3
80104054:	6a 21                	push   $0x21
80104056:	e8 1e ff ff ff       	call   80103f79 <outb>
8010405b:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
8010405e:	6a 11                	push   $0x11
80104060:	68 a0 00 00 00       	push   $0xa0
80104065:	e8 0f ff ff ff       	call   80103f79 <outb>
8010406a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010406d:	6a 28                	push   $0x28
8010406f:	68 a1 00 00 00       	push   $0xa1
80104074:	e8 00 ff ff ff       	call   80103f79 <outb>
80104079:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
8010407c:	6a 02                	push   $0x2
8010407e:	68 a1 00 00 00       	push   $0xa1
80104083:	e8 f1 fe ff ff       	call   80103f79 <outb>
80104088:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
8010408b:	6a 03                	push   $0x3
8010408d:	68 a1 00 00 00       	push   $0xa1
80104092:	e8 e2 fe ff ff       	call   80103f79 <outb>
80104097:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010409a:	6a 68                	push   $0x68
8010409c:	6a 20                	push   $0x20
8010409e:	e8 d6 fe ff ff       	call   80103f79 <outb>
801040a3:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
801040a6:	6a 0a                	push   $0xa
801040a8:	6a 20                	push   $0x20
801040aa:	e8 ca fe ff ff       	call   80103f79 <outb>
801040af:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
801040b2:	6a 68                	push   $0x68
801040b4:	68 a0 00 00 00       	push   $0xa0
801040b9:	e8 bb fe ff ff       	call   80103f79 <outb>
801040be:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
801040c1:	6a 0a                	push   $0xa
801040c3:	68 a0 00 00 00       	push   $0xa0
801040c8:	e8 ac fe ff ff       	call   80103f79 <outb>
801040cd:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
801040d0:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040d7:	66 83 f8 ff          	cmp    $0xffff,%ax
801040db:	74 13                	je     801040f0 <picinit+0xe6>
    picsetmask(irqmask);
801040dd:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
801040e4:	0f b7 c0             	movzwl %ax,%eax
801040e7:	50                   	push   %eax
801040e8:	e8 ab fe ff ff       	call   80103f98 <picsetmask>
801040ed:	83 c4 04             	add    $0x4,%esp
}
801040f0:	90                   	nop
801040f1:	c9                   	leave  
801040f2:	c3                   	ret    

801040f3 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801040f3:	55                   	push   %ebp
801040f4:	89 e5                	mov    %esp,%ebp
801040f6:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
801040f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104100:	8b 45 0c             	mov    0xc(%ebp),%eax
80104103:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010410c:	8b 10                	mov    (%eax),%edx
8010410e:	8b 45 08             	mov    0x8(%ebp),%eax
80104111:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104113:	e8 2d cf ff ff       	call   80101045 <filealloc>
80104118:	89 c2                	mov    %eax,%edx
8010411a:	8b 45 08             	mov    0x8(%ebp),%eax
8010411d:	89 10                	mov    %edx,(%eax)
8010411f:	8b 45 08             	mov    0x8(%ebp),%eax
80104122:	8b 00                	mov    (%eax),%eax
80104124:	85 c0                	test   %eax,%eax
80104126:	0f 84 cb 00 00 00    	je     801041f7 <pipealloc+0x104>
8010412c:	e8 14 cf ff ff       	call   80101045 <filealloc>
80104131:	89 c2                	mov    %eax,%edx
80104133:	8b 45 0c             	mov    0xc(%ebp),%eax
80104136:	89 10                	mov    %edx,(%eax)
80104138:	8b 45 0c             	mov    0xc(%ebp),%eax
8010413b:	8b 00                	mov    (%eax),%eax
8010413d:	85 c0                	test   %eax,%eax
8010413f:	0f 84 b2 00 00 00    	je     801041f7 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104145:	e8 ce eb ff ff       	call   80102d18 <kalloc>
8010414a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010414d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104151:	0f 84 9f 00 00 00    	je     801041f6 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415a:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104161:	00 00 00 
  p->writeopen = 1;
80104164:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104167:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010416e:	00 00 00 
  p->nwrite = 0;
80104171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104174:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010417b:	00 00 00 
  p->nread = 0;
8010417e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104181:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104188:	00 00 00 
  initlock(&p->lock, "pipe");
8010418b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010418e:	83 ec 08             	sub    $0x8,%esp
80104191:	68 7c 96 10 80       	push   $0x8010967c
80104196:	50                   	push   %eax
80104197:	e8 f6 1a 00 00       	call   80105c92 <initlock>
8010419c:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010419f:	8b 45 08             	mov    0x8(%ebp),%eax
801041a2:	8b 00                	mov    (%eax),%eax
801041a4:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801041aa:	8b 45 08             	mov    0x8(%ebp),%eax
801041ad:	8b 00                	mov    (%eax),%eax
801041af:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041b3:	8b 45 08             	mov    0x8(%ebp),%eax
801041b6:	8b 00                	mov    (%eax),%eax
801041b8:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	8b 00                	mov    (%eax),%eax
801041c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041c4:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ca:	8b 00                	mov    (%eax),%eax
801041cc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d5:	8b 00                	mov    (%eax),%eax
801041d7:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801041db:	8b 45 0c             	mov    0xc(%ebp),%eax
801041de:	8b 00                	mov    (%eax),%eax
801041e0:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801041e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041e7:	8b 00                	mov    (%eax),%eax
801041e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ec:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801041ef:	b8 00 00 00 00       	mov    $0x0,%eax
801041f4:	eb 4e                	jmp    80104244 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801041f6:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801041f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801041fb:	74 0e                	je     8010420b <pipealloc+0x118>
    kfree((char*)p);
801041fd:	83 ec 0c             	sub    $0xc,%esp
80104200:	ff 75 f4             	pushl  -0xc(%ebp)
80104203:	e8 73 ea ff ff       	call   80102c7b <kfree>
80104208:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010420b:	8b 45 08             	mov    0x8(%ebp),%eax
8010420e:	8b 00                	mov    (%eax),%eax
80104210:	85 c0                	test   %eax,%eax
80104212:	74 11                	je     80104225 <pipealloc+0x132>
    fileclose(*f0);
80104214:	8b 45 08             	mov    0x8(%ebp),%eax
80104217:	8b 00                	mov    (%eax),%eax
80104219:	83 ec 0c             	sub    $0xc,%esp
8010421c:	50                   	push   %eax
8010421d:	e8 e1 ce ff ff       	call   80101103 <fileclose>
80104222:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104225:	8b 45 0c             	mov    0xc(%ebp),%eax
80104228:	8b 00                	mov    (%eax),%eax
8010422a:	85 c0                	test   %eax,%eax
8010422c:	74 11                	je     8010423f <pipealloc+0x14c>
    fileclose(*f1);
8010422e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104231:	8b 00                	mov    (%eax),%eax
80104233:	83 ec 0c             	sub    $0xc,%esp
80104236:	50                   	push   %eax
80104237:	e8 c7 ce ff ff       	call   80101103 <fileclose>
8010423c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010423f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104244:	c9                   	leave  
80104245:	c3                   	ret    

80104246 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104246:	55                   	push   %ebp
80104247:	89 e5                	mov    %esp,%ebp
80104249:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010424c:	8b 45 08             	mov    0x8(%ebp),%eax
8010424f:	83 ec 0c             	sub    $0xc,%esp
80104252:	50                   	push   %eax
80104253:	e8 5c 1a 00 00       	call   80105cb4 <acquire>
80104258:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010425b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010425f:	74 23                	je     80104284 <pipeclose+0x3e>
    p->writeopen = 0;
80104261:	8b 45 08             	mov    0x8(%ebp),%eax
80104264:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010426b:	00 00 00 
    wakeup(&p->nread);
8010426e:	8b 45 08             	mov    0x8(%ebp),%eax
80104271:	05 34 02 00 00       	add    $0x234,%eax
80104276:	83 ec 0c             	sub    $0xc,%esp
80104279:	50                   	push   %eax
8010427a:	e8 9f 0d 00 00       	call   8010501e <wakeup>
8010427f:	83 c4 10             	add    $0x10,%esp
80104282:	eb 21                	jmp    801042a5 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104284:	8b 45 08             	mov    0x8(%ebp),%eax
80104287:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010428e:	00 00 00 
    wakeup(&p->nwrite);
80104291:	8b 45 08             	mov    0x8(%ebp),%eax
80104294:	05 38 02 00 00       	add    $0x238,%eax
80104299:	83 ec 0c             	sub    $0xc,%esp
8010429c:	50                   	push   %eax
8010429d:	e8 7c 0d 00 00       	call   8010501e <wakeup>
801042a2:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801042a5:	8b 45 08             	mov    0x8(%ebp),%eax
801042a8:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042ae:	85 c0                	test   %eax,%eax
801042b0:	75 2c                	jne    801042de <pipeclose+0x98>
801042b2:	8b 45 08             	mov    0x8(%ebp),%eax
801042b5:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042bb:	85 c0                	test   %eax,%eax
801042bd:	75 1f                	jne    801042de <pipeclose+0x98>
    release(&p->lock);
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	83 ec 0c             	sub    $0xc,%esp
801042c5:	50                   	push   %eax
801042c6:	e8 50 1a 00 00       	call   80105d1b <release>
801042cb:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
801042ce:	83 ec 0c             	sub    $0xc,%esp
801042d1:	ff 75 08             	pushl  0x8(%ebp)
801042d4:	e8 a2 e9 ff ff       	call   80102c7b <kfree>
801042d9:	83 c4 10             	add    $0x10,%esp
801042dc:	eb 0f                	jmp    801042ed <pipeclose+0xa7>
  } else
    release(&p->lock);
801042de:	8b 45 08             	mov    0x8(%ebp),%eax
801042e1:	83 ec 0c             	sub    $0xc,%esp
801042e4:	50                   	push   %eax
801042e5:	e8 31 1a 00 00       	call   80105d1b <release>
801042ea:	83 c4 10             	add    $0x10,%esp
}
801042ed:	90                   	nop
801042ee:	c9                   	leave  
801042ef:	c3                   	ret    

801042f0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801042f0:	55                   	push   %ebp
801042f1:	89 e5                	mov    %esp,%ebp
801042f3:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801042f6:	8b 45 08             	mov    0x8(%ebp),%eax
801042f9:	83 ec 0c             	sub    $0xc,%esp
801042fc:	50                   	push   %eax
801042fd:	e8 b2 19 00 00       	call   80105cb4 <acquire>
80104302:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104305:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010430c:	e9 ad 00 00 00       	jmp    801043be <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104311:	8b 45 08             	mov    0x8(%ebp),%eax
80104314:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010431a:	85 c0                	test   %eax,%eax
8010431c:	74 0d                	je     8010432b <pipewrite+0x3b>
8010431e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104324:	8b 40 24             	mov    0x24(%eax),%eax
80104327:	85 c0                	test   %eax,%eax
80104329:	74 19                	je     80104344 <pipewrite+0x54>
        release(&p->lock);
8010432b:	8b 45 08             	mov    0x8(%ebp),%eax
8010432e:	83 ec 0c             	sub    $0xc,%esp
80104331:	50                   	push   %eax
80104332:	e8 e4 19 00 00       	call   80105d1b <release>
80104337:	83 c4 10             	add    $0x10,%esp
        return -1;
8010433a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010433f:	e9 a8 00 00 00       	jmp    801043ec <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104344:	8b 45 08             	mov    0x8(%ebp),%eax
80104347:	05 34 02 00 00       	add    $0x234,%eax
8010434c:	83 ec 0c             	sub    $0xc,%esp
8010434f:	50                   	push   %eax
80104350:	e8 c9 0c 00 00       	call   8010501e <wakeup>
80104355:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104358:	8b 45 08             	mov    0x8(%ebp),%eax
8010435b:	8b 55 08             	mov    0x8(%ebp),%edx
8010435e:	81 c2 38 02 00 00    	add    $0x238,%edx
80104364:	83 ec 08             	sub    $0x8,%esp
80104367:	50                   	push   %eax
80104368:	52                   	push   %edx
80104369:	e8 9b 0b 00 00       	call   80104f09 <sleep>
8010436e:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104371:	8b 45 08             	mov    0x8(%ebp),%eax
80104374:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010437a:	8b 45 08             	mov    0x8(%ebp),%eax
8010437d:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104383:	05 00 02 00 00       	add    $0x200,%eax
80104388:	39 c2                	cmp    %eax,%edx
8010438a:	74 85                	je     80104311 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010438c:	8b 45 08             	mov    0x8(%ebp),%eax
8010438f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104395:	8d 48 01             	lea    0x1(%eax),%ecx
80104398:	8b 55 08             	mov    0x8(%ebp),%edx
8010439b:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801043a1:	25 ff 01 00 00       	and    $0x1ff,%eax
801043a6:	89 c1                	mov    %eax,%ecx
801043a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801043ae:	01 d0                	add    %edx,%eax
801043b0:	0f b6 10             	movzbl (%eax),%edx
801043b3:	8b 45 08             	mov    0x8(%ebp),%eax
801043b6:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043ba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c1:	3b 45 10             	cmp    0x10(%ebp),%eax
801043c4:	7c ab                	jl     80104371 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043c6:	8b 45 08             	mov    0x8(%ebp),%eax
801043c9:	05 34 02 00 00       	add    $0x234,%eax
801043ce:	83 ec 0c             	sub    $0xc,%esp
801043d1:	50                   	push   %eax
801043d2:	e8 47 0c 00 00       	call   8010501e <wakeup>
801043d7:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801043da:	8b 45 08             	mov    0x8(%ebp),%eax
801043dd:	83 ec 0c             	sub    $0xc,%esp
801043e0:	50                   	push   %eax
801043e1:	e8 35 19 00 00       	call   80105d1b <release>
801043e6:	83 c4 10             	add    $0x10,%esp
  return n;
801043e9:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043ec:	c9                   	leave  
801043ed:	c3                   	ret    

801043ee <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043ee:	55                   	push   %ebp
801043ef:	89 e5                	mov    %esp,%ebp
801043f1:	53                   	push   %ebx
801043f2:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801043f5:	8b 45 08             	mov    0x8(%ebp),%eax
801043f8:	83 ec 0c             	sub    $0xc,%esp
801043fb:	50                   	push   %eax
801043fc:	e8 b3 18 00 00       	call   80105cb4 <acquire>
80104401:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104404:	eb 3f                	jmp    80104445 <piperead+0x57>
    if(proc->killed){
80104406:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010440c:	8b 40 24             	mov    0x24(%eax),%eax
8010440f:	85 c0                	test   %eax,%eax
80104411:	74 19                	je     8010442c <piperead+0x3e>
      release(&p->lock);
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	83 ec 0c             	sub    $0xc,%esp
80104419:	50                   	push   %eax
8010441a:	e8 fc 18 00 00       	call   80105d1b <release>
8010441f:	83 c4 10             	add    $0x10,%esp
      return -1;
80104422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104427:	e9 bf 00 00 00       	jmp    801044eb <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010442c:	8b 45 08             	mov    0x8(%ebp),%eax
8010442f:	8b 55 08             	mov    0x8(%ebp),%edx
80104432:	81 c2 34 02 00 00    	add    $0x234,%edx
80104438:	83 ec 08             	sub    $0x8,%esp
8010443b:	50                   	push   %eax
8010443c:	52                   	push   %edx
8010443d:	e8 c7 0a 00 00       	call   80104f09 <sleep>
80104442:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104445:	8b 45 08             	mov    0x8(%ebp),%eax
80104448:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010444e:	8b 45 08             	mov    0x8(%ebp),%eax
80104451:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104457:	39 c2                	cmp    %eax,%edx
80104459:	75 0d                	jne    80104468 <piperead+0x7a>
8010445b:	8b 45 08             	mov    0x8(%ebp),%eax
8010445e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104464:	85 c0                	test   %eax,%eax
80104466:	75 9e                	jne    80104406 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104468:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010446f:	eb 49                	jmp    801044ba <piperead+0xcc>
    if(p->nread == p->nwrite)
80104471:	8b 45 08             	mov    0x8(%ebp),%eax
80104474:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010447a:	8b 45 08             	mov    0x8(%ebp),%eax
8010447d:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104483:	39 c2                	cmp    %eax,%edx
80104485:	74 3d                	je     801044c4 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104487:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010448a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010448d:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104490:	8b 45 08             	mov    0x8(%ebp),%eax
80104493:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104499:	8d 48 01             	lea    0x1(%eax),%ecx
8010449c:	8b 55 08             	mov    0x8(%ebp),%edx
8010449f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801044a5:	25 ff 01 00 00       	and    $0x1ff,%eax
801044aa:	89 c2                	mov    %eax,%edx
801044ac:	8b 45 08             	mov    0x8(%ebp),%eax
801044af:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801044b4:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044b6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801044ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bd:	3b 45 10             	cmp    0x10(%ebp),%eax
801044c0:	7c af                	jl     80104471 <piperead+0x83>
801044c2:	eb 01                	jmp    801044c5 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801044c4:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044c5:	8b 45 08             	mov    0x8(%ebp),%eax
801044c8:	05 38 02 00 00       	add    $0x238,%eax
801044cd:	83 ec 0c             	sub    $0xc,%esp
801044d0:	50                   	push   %eax
801044d1:	e8 48 0b 00 00       	call   8010501e <wakeup>
801044d6:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
801044d9:	8b 45 08             	mov    0x8(%ebp),%eax
801044dc:	83 ec 0c             	sub    $0xc,%esp
801044df:	50                   	push   %eax
801044e0:	e8 36 18 00 00       	call   80105d1b <release>
801044e5:	83 c4 10             	add    $0x10,%esp
  return i;
801044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044ee:	c9                   	leave  
801044ef:	c3                   	ret    

801044f0 <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
801044f0:	55                   	push   %ebp
801044f1:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
801044f3:	f4                   	hlt    
}
801044f4:	90                   	nop
801044f5:	5d                   	pop    %ebp
801044f6:	c3                   	ret    

801044f7 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044f7:	55                   	push   %ebp
801044f8:	89 e5                	mov    %esp,%ebp
801044fa:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044fd:	9c                   	pushf  
801044fe:	58                   	pop    %eax
801044ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104502:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104505:	c9                   	leave  
80104506:	c3                   	ret    

80104507 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104507:	55                   	push   %ebp
80104508:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010450a:	fb                   	sti    
}
8010450b:	90                   	nop
8010450c:	5d                   	pop    %ebp
8010450d:	c3                   	ret    

8010450e <pinit>:
static void list_display(struct proc*);
#endif

void
pinit(void)
{
8010450e:	55                   	push   %ebp
8010450f:	89 e5                	mov    %esp,%ebp
80104511:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104514:	83 ec 08             	sub    $0x8,%esp
80104517:	68 84 96 10 80       	push   $0x80109684
8010451c:	68 80 39 11 80       	push   $0x80113980
80104521:	e8 6c 17 00 00       	call   80105c92 <initlock>
80104526:	83 c4 10             	add    $0x10,%esp
}
80104529:	90                   	nop
8010452a:	c9                   	leave  
8010452b:	c3                   	ret    

8010452c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010452c:	55                   	push   %ebp
8010452d:	89 e5                	mov    %esp,%ebp
8010452f:	83 ec 18             	sub    $0x18,%esp
//cprintf("entering allocproc()\n");
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104532:	83 ec 0c             	sub    $0xc,%esp
80104535:	68 80 39 11 80       	push   $0x80113980
8010453a:	e8 75 17 00 00       	call   80105cb4 <acquire>
8010453f:	83 c4 10             	add    $0x10,%esp
  #ifdef CS333_P3P4
  p = ptable.pLists.free;
80104542:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80104547:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (p)
8010454a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010454e:	75 1a                	jne    8010456a <allocproc+0x3e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    if(p->state == UNUSED)
      goto found;
  }
  #endif
  release(&ptable.lock);
80104550:	83 ec 0c             	sub    $0xc,%esp
80104553:	68 80 39 11 80       	push   $0x80113980
80104558:	e8 be 17 00 00       	call   80105d1b <release>
8010455d:	83 c4 10             	add    $0x10,%esp
  return 0;
80104560:	b8 00 00 00 00       	mov    $0x0,%eax
80104565:	e9 ef 00 00 00       	jmp    80104659 <allocproc+0x12d>

  acquire(&ptable.lock);
  #ifdef CS333_P3P4
  p = ptable.pLists.free;
  if (p)
    goto found;
8010456a:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  #ifdef CS333_P3P4
  statelist_move_from_to(UNUSED, EMBRYO, p);
8010456b:	83 ec 04             	sub    $0x4,%esp
8010456e:	ff 75 f4             	pushl  -0xc(%ebp)
80104571:	6a 01                	push   $0x1
80104573:	6a 00                	push   $0x0
80104575:	e8 49 11 00 00       	call   801056c3 <statelist_move_from_to>
8010457a:	83 c4 10             	add    $0x10,%esp
  #else
  p->state = EMBRYO;
  #endif
  p->pid = nextpid++;
8010457d:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104582:	8d 50 01             	lea    0x1(%eax),%edx
80104585:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
8010458b:	89 c2                	mov    %eax,%edx
8010458d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104590:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
80104593:	83 ec 0c             	sub    $0xc,%esp
80104596:	68 80 39 11 80       	push   $0x80113980
8010459b:	e8 7b 17 00 00       	call   80105d1b <release>
801045a0:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045a3:	e8 70 e7 ff ff       	call   80102d18 <kalloc>
801045a8:	89 c2                	mov    %eax,%edx
801045aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ad:	89 50 08             	mov    %edx,0x8(%eax)
801045b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b3:	8b 40 08             	mov    0x8(%eax),%eax
801045b6:	85 c0                	test   %eax,%eax
801045b8:	75 1c                	jne    801045d6 <allocproc+0xaa>
    #ifdef CS333_P3P4
    statelist_move_from_to(EMBRYO, UNUSED, p);
801045ba:	83 ec 04             	sub    $0x4,%esp
801045bd:	ff 75 f4             	pushl  -0xc(%ebp)
801045c0:	6a 00                	push   $0x0
801045c2:	6a 01                	push   $0x1
801045c4:	e8 fa 10 00 00       	call   801056c3 <statelist_move_from_to>
801045c9:	83 c4 10             	add    $0x10,%esp
    #else
    p->state = UNUSED;
    #endif
    return 0;
801045cc:	b8 00 00 00 00       	mov    $0x0,%eax
801045d1:	e9 83 00 00 00       	jmp    80104659 <allocproc+0x12d>
  }
  sp = p->kstack + KSTACKSIZE;
801045d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d9:	8b 40 08             	mov    0x8(%eax),%eax
801045dc:	05 00 10 00 00       	add    $0x1000,%eax
801045e1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801045e4:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801045e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045eb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045ee:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801045f1:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801045f5:	ba 53 74 10 80       	mov    $0x80107453,%edx
801045fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045fd:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801045ff:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104603:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104606:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104609:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460f:	8b 40 1c             	mov    0x1c(%eax),%eax
80104612:	83 ec 04             	sub    $0x4,%esp
80104615:	6a 14                	push   $0x14
80104617:	6a 00                	push   $0x0
80104619:	50                   	push   %eax
8010461a:	e8 f8 18 00 00       	call   80105f17 <memset>
8010461f:	83 c4 10             	add    $0x10,%esp
//cprintf("entering forkret() from allocproc()\n");
  p->context->eip = (uint)forkret;
80104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104625:	8b 40 1c             	mov    0x1c(%eax),%eax
80104628:	ba c3 4e 10 80       	mov    $0x80104ec3,%edx
8010462d:	89 50 10             	mov    %edx,0x10(%eax)
//cprintf("returned to allocproc() from forkret()\n");

//student added
  #ifdef CS333_P1
  p->start_ticks = ticks;
80104630:	8b 15 00 67 11 80    	mov    0x80116700,%edx
80104636:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104639:	89 50 7c             	mov    %edx,0x7c(%eax)
  #endif
  #ifdef CS333_P2
  p->cpu_ticks_total = 0;
8010463c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463f:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104646:	00 00 00 
  p->cpu_ticks_in = 0;
80104649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464c:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80104653:	00 00 00 
  #endif

//cprintf("leaving allocproc()\n");
  return p;
80104656:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104659:	c9                   	leave  
8010465a:	c3                   	ret    

8010465b <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010465b:	55                   	push   %ebp
8010465c:	89 e5                	mov    %esp,%ebp
8010465e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

//cprintf("entering userinit()\n");
  #ifdef CS333_P3P4
  acquire(&ptable.lock);
80104661:	83 ec 0c             	sub    $0xc,%esp
80104664:	68 80 39 11 80       	push   $0x80113980
80104669:	e8 46 16 00 00       	call   80105cb4 <acquire>
8010466e:	83 c4 10             	add    $0x10,%esp
  initProcessLists();
80104671:	e8 69 0f 00 00       	call   801055df <initProcessLists>
  initFreeList();
80104676:	e8 e2 0f 00 00       	call   8010565d <initFreeList>
  release(&ptable.lock);
8010467b:	83 ec 0c             	sub    $0xc,%esp
8010467e:	68 80 39 11 80       	push   $0x80113980
80104683:	e8 93 16 00 00       	call   80105d1b <release>
80104688:	83 c4 10             	add    $0x10,%esp
  #endif

  p = allocproc();
8010468b:	e8 9c fe ff ff       	call   8010452c <allocproc>
80104690:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104696:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
8010469b:	e8 75 44 00 00       	call   80108b15 <setupkvm>
801046a0:	89 c2                	mov    %eax,%edx
801046a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a5:	89 50 04             	mov    %edx,0x4(%eax)
801046a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ab:	8b 40 04             	mov    0x4(%eax),%eax
801046ae:	85 c0                	test   %eax,%eax
801046b0:	75 0d                	jne    801046bf <userinit+0x64>
    panic("userinit: out of memory?");
801046b2:	83 ec 0c             	sub    $0xc,%esp
801046b5:	68 8b 96 10 80       	push   $0x8010968b
801046ba:	e8 a7 be ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046bf:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c7:	8b 40 04             	mov    0x4(%eax),%eax
801046ca:	83 ec 04             	sub    $0x4,%esp
801046cd:	52                   	push   %edx
801046ce:	68 00 c5 10 80       	push   $0x8010c500
801046d3:	50                   	push   %eax
801046d4:	e8 96 46 00 00       	call   80108d6f <inituvm>
801046d9:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801046dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046df:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e8:	8b 40 18             	mov    0x18(%eax),%eax
801046eb:	83 ec 04             	sub    $0x4,%esp
801046ee:	6a 4c                	push   $0x4c
801046f0:	6a 00                	push   $0x0
801046f2:	50                   	push   %eax
801046f3:	e8 1f 18 00 00       	call   80105f17 <memset>
801046f8:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fe:	8b 40 18             	mov    0x18(%eax),%eax
80104701:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470a:	8b 40 18             	mov    0x18(%eax),%eax
8010470d:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104716:	8b 40 18             	mov    0x18(%eax),%eax
80104719:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010471c:	8b 52 18             	mov    0x18(%edx),%edx
8010471f:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104723:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472a:	8b 40 18             	mov    0x18(%eax),%eax
8010472d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104730:	8b 52 18             	mov    0x18(%edx),%edx
80104733:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104737:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010473b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473e:	8b 40 18             	mov    0x18(%eax),%eax
80104741:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104748:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474b:	8b 40 18             	mov    0x18(%eax),%eax
8010474e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104758:	8b 40 18             	mov    0x18(%eax),%eax
8010475b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104762:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104765:	83 c0 6c             	add    $0x6c,%eax
80104768:	83 ec 04             	sub    $0x4,%esp
8010476b:	6a 10                	push   $0x10
8010476d:	68 a4 96 10 80       	push   $0x801096a4
80104772:	50                   	push   %eax
80104773:	e8 a2 19 00 00       	call   8010611a <safestrcpy>
80104778:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010477b:	83 ec 0c             	sub    $0xc,%esp
8010477e:	68 ad 96 10 80       	push   $0x801096ad
80104783:	e8 52 de ff ff       	call   801025da <namei>
80104788:	83 c4 10             	add    $0x10,%esp
8010478b:	89 c2                	mov    %eax,%edx
8010478d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104790:	89 50 68             	mov    %edx,0x68(%eax)

  #ifdef CS333_P2
  p->parent = 0;
80104793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104796:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  p->uid = DEFAULT_UID;
8010479d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a0:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801047a7:	00 00 00 
  p->gid = DEFAULT_GID;
801047aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ad:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801047b4:	00 00 00 
  #endif

  #ifdef CS333_P3P4
  acquire(&ptable.lock);
801047b7:	83 ec 0c             	sub    $0xc,%esp
801047ba:	68 80 39 11 80       	push   $0x80113980
801047bf:	e8 f0 14 00 00       	call   80105cb4 <acquire>
801047c4:	83 c4 10             	add    $0x10,%esp
  statelist_move_from_to(EMBRYO, RUNNABLE, p);
801047c7:	83 ec 04             	sub    $0x4,%esp
801047ca:	ff 75 f4             	pushl  -0xc(%ebp)
801047cd:	6a 03                	push   $0x3
801047cf:	6a 01                	push   $0x1
801047d1:	e8 ed 0e 00 00       	call   801056c3 <statelist_move_from_to>
801047d6:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801047d9:	83 ec 0c             	sub    $0xc,%esp
801047dc:	68 80 39 11 80       	push   $0x80113980
801047e1:	e8 35 15 00 00       	call   80105d1b <release>
801047e6:	83 c4 10             	add    $0x10,%esp
  #else
  p->state = RUNNABLE;
  #endif
//cprintf("leaving userinit()\n");
}
801047e9:	90                   	nop
801047ea:	c9                   	leave  
801047eb:	c3                   	ret    

801047ec <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801047ec:	55                   	push   %ebp
801047ed:	89 e5                	mov    %esp,%ebp
801047ef:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
801047f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047f8:	8b 00                	mov    (%eax),%eax
801047fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801047fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104801:	7e 31                	jle    80104834 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104803:	8b 55 08             	mov    0x8(%ebp),%edx
80104806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104809:	01 c2                	add    %eax,%edx
8010480b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104811:	8b 40 04             	mov    0x4(%eax),%eax
80104814:	83 ec 04             	sub    $0x4,%esp
80104817:	52                   	push   %edx
80104818:	ff 75 f4             	pushl  -0xc(%ebp)
8010481b:	50                   	push   %eax
8010481c:	e8 9b 46 00 00       	call   80108ebc <allocuvm>
80104821:	83 c4 10             	add    $0x10,%esp
80104824:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104827:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010482b:	75 3e                	jne    8010486b <growproc+0x7f>
      return -1;
8010482d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104832:	eb 59                	jmp    8010488d <growproc+0xa1>
  } else if(n < 0){
80104834:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104838:	79 31                	jns    8010486b <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010483a:	8b 55 08             	mov    0x8(%ebp),%edx
8010483d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104840:	01 c2                	add    %eax,%edx
80104842:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104848:	8b 40 04             	mov    0x4(%eax),%eax
8010484b:	83 ec 04             	sub    $0x4,%esp
8010484e:	52                   	push   %edx
8010484f:	ff 75 f4             	pushl  -0xc(%ebp)
80104852:	50                   	push   %eax
80104853:	e8 2d 47 00 00       	call   80108f85 <deallocuvm>
80104858:	83 c4 10             	add    $0x10,%esp
8010485b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010485e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104862:	75 07                	jne    8010486b <growproc+0x7f>
      return -1;
80104864:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104869:	eb 22                	jmp    8010488d <growproc+0xa1>
  }
  proc->sz = sz;
8010486b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104871:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104874:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104876:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010487c:	83 ec 0c             	sub    $0xc,%esp
8010487f:	50                   	push   %eax
80104880:	e8 77 43 00 00       	call   80108bfc <switchuvm>
80104885:	83 c4 10             	add    $0x10,%esp
  return 0;
80104888:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010488d:	c9                   	leave  
8010488e:	c3                   	ret    

8010488f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010488f:	55                   	push   %ebp
80104890:	89 e5                	mov    %esp,%ebp
80104892:	57                   	push   %edi
80104893:	56                   	push   %esi
80104894:	53                   	push   %ebx
80104895:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
//cprintf("entering fork\n");

  // Allocate process.
  if((np = allocproc()) == 0)
80104898:	e8 8f fc ff ff       	call   8010452c <allocproc>
8010489d:	89 45 e0             	mov    %eax,-0x20(%ebp)
801048a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801048a4:	75 0a                	jne    801048b0 <fork+0x21>
    return -1;
801048a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ab:	e9 a2 01 00 00       	jmp    80104a52 <fork+0x1c3>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801048b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048b6:	8b 10                	mov    (%eax),%edx
801048b8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048be:	8b 40 04             	mov    0x4(%eax),%eax
801048c1:	83 ec 08             	sub    $0x8,%esp
801048c4:	52                   	push   %edx
801048c5:	50                   	push   %eax
801048c6:	e8 58 48 00 00       	call   80109123 <copyuvm>
801048cb:	83 c4 10             	add    $0x10,%esp
801048ce:	89 c2                	mov    %eax,%edx
801048d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d3:	89 50 04             	mov    %edx,0x4(%eax)
801048d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d9:	8b 40 04             	mov    0x4(%eax),%eax
801048dc:	85 c0                	test   %eax,%eax
801048de:	75 38                	jne    80104918 <fork+0x89>
    kfree(np->kstack);
801048e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e3:	8b 40 08             	mov    0x8(%eax),%eax
801048e6:	83 ec 0c             	sub    $0xc,%esp
801048e9:	50                   	push   %eax
801048ea:	e8 8c e3 ff ff       	call   80102c7b <kfree>
801048ef:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801048f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    #ifdef CS333_P3P4
    statelist_move_from_to(EMBRYO, UNUSED, np);
801048fc:	83 ec 04             	sub    $0x4,%esp
801048ff:	ff 75 e0             	pushl  -0x20(%ebp)
80104902:	6a 00                	push   $0x0
80104904:	6a 01                	push   $0x1
80104906:	e8 b8 0d 00 00       	call   801056c3 <statelist_move_from_to>
8010490b:	83 c4 10             	add    $0x10,%esp
    #else
    np->state = UNUSED;
    #endif
    return -1;
8010490e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104913:	e9 3a 01 00 00       	jmp    80104a52 <fork+0x1c3>
  }
  np->sz = proc->sz;
80104918:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491e:	8b 10                	mov    (%eax),%edx
80104920:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104923:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104925:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010492c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010492f:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104932:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104935:	8b 50 18             	mov    0x18(%eax),%edx
80104938:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010493e:	8b 40 18             	mov    0x18(%eax),%eax
80104941:	89 c3                	mov    %eax,%ebx
80104943:	b8 13 00 00 00       	mov    $0x13,%eax
80104948:	89 d7                	mov    %edx,%edi
8010494a:	89 de                	mov    %ebx,%esi
8010494c:	89 c1                	mov    %eax,%ecx
8010494e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104950:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104953:	8b 40 18             	mov    0x18(%eax),%eax
80104956:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010495d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104964:	eb 43                	jmp    801049a9 <fork+0x11a>
    if(proc->ofile[i])
80104966:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010496f:	83 c2 08             	add    $0x8,%edx
80104972:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104976:	85 c0                	test   %eax,%eax
80104978:	74 2b                	je     801049a5 <fork+0x116>
      np->ofile[i] = filedup(proc->ofile[i]);
8010497a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104980:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104983:	83 c2 08             	add    $0x8,%edx
80104986:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010498a:	83 ec 0c             	sub    $0xc,%esp
8010498d:	50                   	push   %eax
8010498e:	e8 1f c7 ff ff       	call   801010b2 <filedup>
80104993:	83 c4 10             	add    $0x10,%esp
80104996:	89 c1                	mov    %eax,%ecx
80104998:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010499b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010499e:	83 c2 08             	add    $0x8,%edx
801049a1:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801049a5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801049a9:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049ad:	7e b7                	jle    80104966 <fork+0xd7>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801049af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b5:	8b 40 68             	mov    0x68(%eax),%eax
801049b8:	83 ec 0c             	sub    $0xc,%esp
801049bb:	50                   	push   %eax
801049bc:	e8 21 d0 ff ff       	call   801019e2 <idup>
801049c1:	83 c4 10             	add    $0x10,%esp
801049c4:	89 c2                	mov    %eax,%edx
801049c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049c9:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801049cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d2:	8d 50 6c             	lea    0x6c(%eax),%edx
801049d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049d8:	83 c0 6c             	add    $0x6c,%eax
801049db:	83 ec 04             	sub    $0x4,%esp
801049de:	6a 10                	push   $0x10
801049e0:	52                   	push   %edx
801049e1:	50                   	push   %eax
801049e2:	e8 33 17 00 00       	call   8010611a <safestrcpy>
801049e7:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801049ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049ed:	8b 40 10             	mov    0x10(%eax),%eax
801049f0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  #ifdef CS333_P2
  np->uid = proc->uid;
801049f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049f9:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801049ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a02:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104a08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a0e:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104a14:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a17:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104a1d:	83 ec 0c             	sub    $0xc,%esp
80104a20:	68 80 39 11 80       	push   $0x80113980
80104a25:	e8 8a 12 00 00       	call   80105cb4 <acquire>
80104a2a:	83 c4 10             	add    $0x10,%esp
  #ifdef CS333_P3P4
  statelist_move_from_to(EMBRYO, RUNNABLE, np);
80104a2d:	83 ec 04             	sub    $0x4,%esp
80104a30:	ff 75 e0             	pushl  -0x20(%ebp)
80104a33:	6a 03                	push   $0x3
80104a35:	6a 01                	push   $0x1
80104a37:	e8 87 0c 00 00       	call   801056c3 <statelist_move_from_to>
80104a3c:	83 c4 10             	add    $0x10,%esp
  #else
  np->state = RUNNABLE;
  #endif
  release(&ptable.lock);
80104a3f:	83 ec 0c             	sub    $0xc,%esp
80104a42:	68 80 39 11 80       	push   $0x80113980
80104a47:	e8 cf 12 00 00       	call   80105d1b <release>
80104a4c:	83 c4 10             	add    $0x10,%esp

//cprintf("leaving fork\n");
  return pid;
80104a4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104a52:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a55:	5b                   	pop    %ebx
80104a56:	5e                   	pop    %esi
80104a57:	5f                   	pop    %edi
80104a58:	5d                   	pop    %ebp
80104a59:	c3                   	ret    

80104a5a <exit>:
  panic("zombie exit");
}
#else
void
exit(void)
{
80104a5a:	55                   	push   %ebp
80104a5b:	89 e5                	mov    %esp,%ebp
80104a5d:	83 ec 18             	sub    $0x18,%esp
  //struct proc *p;
  int fd;
//cprintf("entering exit()\n");

  if(proc == initproc)
80104a60:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104a67:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104a6c:	39 c2                	cmp    %eax,%edx
80104a6e:	75 0d                	jne    80104a7d <exit+0x23>
    panic("init exiting");
80104a70:	83 ec 0c             	sub    $0xc,%esp
80104a73:	68 af 96 10 80       	push   $0x801096af
80104a78:	e8 e9 ba ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104a84:	eb 48                	jmp    80104ace <exit+0x74>
    if(proc->ofile[fd]){
80104a86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a8f:	83 c2 08             	add    $0x8,%edx
80104a92:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a96:	85 c0                	test   %eax,%eax
80104a98:	74 30                	je     80104aca <exit+0x70>
      fileclose(proc->ofile[fd]);
80104a9a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104aa0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104aa3:	83 c2 08             	add    $0x8,%edx
80104aa6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104aaa:	83 ec 0c             	sub    $0xc,%esp
80104aad:	50                   	push   %eax
80104aae:	e8 50 c6 ff ff       	call   80101103 <fileclose>
80104ab3:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104ab6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104abc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104abf:	83 c2 08             	add    $0x8,%edx
80104ac2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104ac9:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104aca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ace:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104ad2:	7e b2                	jle    80104a86 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104ad4:	e8 26 eb ff ff       	call   801035ff <begin_op>
  iput(proc->cwd);
80104ad9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104adf:	8b 40 68             	mov    0x68(%eax),%eax
80104ae2:	83 ec 0c             	sub    $0xc,%esp
80104ae5:	50                   	push   %eax
80104ae6:	e8 01 d1 ff ff       	call   80101bec <iput>
80104aeb:	83 c4 10             	add    $0x10,%esp
  end_op();
80104aee:	e8 98 eb ff ff       	call   8010368b <end_op>
  proc->cwd = 0;
80104af3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104af9:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104b00:	83 ec 0c             	sub    $0xc,%esp
80104b03:	68 80 39 11 80       	push   $0x80113980
80104b08:	e8 a7 11 00 00       	call   80105cb4 <acquire>
80104b0d:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104b10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b16:	8b 40 14             	mov    0x14(%eax),%eax
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	50                   	push   %eax
80104b1d:	e8 95 04 00 00       	call   80104fb7 <wakeup1>
80104b22:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  statelist_abandon_children(proc);
80104b25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2b:	83 ec 0c             	sub    $0xc,%esp
80104b2e:	50                   	push   %eax
80104b2f:	e8 4f 0e 00 00       	call   80105983 <statelist_abandon_children>
80104b34:	83 c4 10             	add    $0x10,%esp
  // Jump into the scheduler, never to return.
  statelist_move_from_to(RUNNING, ZOMBIE, proc);
80104b37:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b3d:	83 ec 04             	sub    $0x4,%esp
80104b40:	50                   	push   %eax
80104b41:	6a 05                	push   $0x5
80104b43:	6a 04                	push   $0x4
80104b45:	e8 79 0b 00 00       	call   801056c3 <statelist_move_from_to>
80104b4a:	83 c4 10             	add    $0x10,%esp

//cprintf("calling sched() from exit()\n");

  sched();
80104b4d:	e8 3b 02 00 00       	call   80104d8d <sched>
  panic("zombie exit");
80104b52:	83 ec 0c             	sub    $0xc,%esp
80104b55:	68 bc 96 10 80       	push   $0x801096bc
80104b5a:	e8 07 ba ff ff       	call   80100566 <panic>

80104b5f <wait>:
  }
}
#else
int
wait(void)
{
80104b5f:	55                   	push   %ebp
80104b60:	89 e5                	mov    %esp,%ebp
80104b62:	83 ec 18             	sub    $0x18,%esp
//cprintf("entering wait()\n");
  struct proc *p;
  int havekids, pid, state;

  acquire(&ptable.lock);
80104b65:	83 ec 0c             	sub    $0xc,%esp
80104b68:	68 80 39 11 80       	push   $0x80113980
80104b6d:	e8 42 11 00 00       	call   80105cb4 <acquire>
80104b72:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104b75:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (state = 1; state <= ZOMBIE; ++state) {
80104b7c:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
80104b83:	e9 eb 00 00 00       	jmp    80104c73 <wait+0x114>
      p = get_head(state);
80104b88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b8b:	83 ec 0c             	sub    $0xc,%esp
80104b8e:	50                   	push   %eax
80104b8f:	e8 3e 0d 00 00       	call   801058d2 <get_head>
80104b94:	83 c4 10             	add    $0x10,%esp
80104b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
      while (p) {
80104b9a:	e9 c6 00 00 00       	jmp    80104c65 <wait+0x106>
        if(p->parent != proc) {
80104b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba2:	8b 50 14             	mov    0x14(%eax),%edx
80104ba5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bab:	39 c2                	cmp    %eax,%edx
80104bad:	74 11                	je     80104bc0 <wait+0x61>
          p = p->next;
80104baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb2:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
          continue;
80104bbb:	e9 a5 00 00 00       	jmp    80104c65 <wait+0x106>
        }
        havekids = 1;
80104bc0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
        if(p->state == ZOMBIE){
80104bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bca:	8b 40 0c             	mov    0xc(%eax),%eax
80104bcd:	83 f8 05             	cmp    $0x5,%eax
80104bd0:	0f 85 83 00 00 00    	jne    80104c59 <wait+0xfa>
          // Found one.
          pid = p->pid;
80104bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd9:	8b 40 10             	mov    0x10(%eax),%eax
80104bdc:	89 45 e8             	mov    %eax,-0x18(%ebp)
          kfree(p->kstack);
80104bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be2:	8b 40 08             	mov    0x8(%eax),%eax
80104be5:	83 ec 0c             	sub    $0xc,%esp
80104be8:	50                   	push   %eax
80104be9:	e8 8d e0 ff ff       	call   80102c7b <kfree>
80104bee:	83 c4 10             	add    $0x10,%esp
          p->kstack = 0;
80104bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
          freevm(p->pgdir);
80104bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfe:	8b 40 04             	mov    0x4(%eax),%eax
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	50                   	push   %eax
80104c05:	e8 38 44 00 00       	call   80109042 <freevm>
80104c0a:	83 c4 10             	add    $0x10,%esp
          statelist_move_from_to(ZOMBIE, UNUSED, p);
80104c0d:	83 ec 04             	sub    $0x4,%esp
80104c10:	ff 75 f4             	pushl  -0xc(%ebp)
80104c13:	6a 00                	push   $0x0
80104c15:	6a 05                	push   $0x5
80104c17:	e8 a7 0a 00 00       	call   801056c3 <statelist_move_from_to>
80104c1c:	83 c4 10             	add    $0x10,%esp
          p->pid = 0;
80104c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c22:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
          p->parent = 0;
80104c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
          p->name[0] = 0;
80104c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c36:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
          p->killed = 0;
80104c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3d:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
          release(&ptable.lock);
80104c44:	83 ec 0c             	sub    $0xc,%esp
80104c47:	68 80 39 11 80       	push   $0x80113980
80104c4c:	e8 ca 10 00 00       	call   80105d1b <release>
80104c51:	83 c4 10             	add    $0x10,%esp
          return pid;
80104c54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c57:	eb 6a                	jmp    80104cc3 <wait+0x164>
        }
        p = p->next;
80104c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5c:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for (state = 1; state <= ZOMBIE; ++state) {
      p = get_head(state);
      while (p) {
80104c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104c69:	0f 85 30 ff ff ff    	jne    80104b9f <wait+0x40>

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for (state = 1; state <= ZOMBIE; ++state) {
80104c6f:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80104c73:	83 7d ec 05          	cmpl   $0x5,-0x14(%ebp)
80104c77:	0f 8e 0b ff ff ff    	jle    80104b88 <wait+0x29>
        p = p->next;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104c7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c81:	74 0d                	je     80104c90 <wait+0x131>
80104c83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c89:	8b 40 24             	mov    0x24(%eax),%eax
80104c8c:	85 c0                	test   %eax,%eax
80104c8e:	74 17                	je     80104ca7 <wait+0x148>
      release(&ptable.lock);
80104c90:	83 ec 0c             	sub    $0xc,%esp
80104c93:	68 80 39 11 80       	push   $0x80113980
80104c98:	e8 7e 10 00 00       	call   80105d1b <release>
80104c9d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104ca0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ca5:	eb 1c                	jmp    80104cc3 <wait+0x164>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104ca7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cad:	83 ec 08             	sub    $0x8,%esp
80104cb0:	68 80 39 11 80       	push   $0x80113980
80104cb5:	50                   	push   %eax
80104cb6:	e8 4e 02 00 00       	call   80104f09 <sleep>
80104cbb:	83 c4 10             	add    $0x10,%esp
  }
80104cbe:	e9 b2 fe ff ff       	jmp    80104b75 <wait+0x16>
//cprintf("leaving wait()\n");
}
80104cc3:	c9                   	leave  
80104cc4:	c3                   	ret    

80104cc5 <scheduler>:
}

#else // if CS333_P3P4
void
scheduler(void)
{
80104cc5:	55                   	push   %ebp
80104cc6:	89 e5                	mov    %esp,%ebp
80104cc8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104ccb:	e8 37 f8 ff ff       	call   80104507 <sti>

    idle = 1;  // assume idle unless we schedule a process
80104cd0:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    acquire(&ptable.lock);
80104cd7:	83 ec 0c             	sub    $0xc,%esp
80104cda:	68 80 39 11 80       	push   $0x80113980
80104cdf:	e8 d0 0f 00 00       	call   80105cb4 <acquire>
80104ce4:	83 c4 10             	add    $0x10,%esp
    p = ptable.pLists.ready;
80104ce7:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80104cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(p) {
80104cef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104cf3:	74 6f                	je     80104d64 <scheduler+0x9f>
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
80104cf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
      proc = p;
80104cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cff:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104d05:	83 ec 0c             	sub    $0xc,%esp
80104d08:	ff 75 f0             	pushl  -0x10(%ebp)
80104d0b:	e8 ec 3e 00 00       	call   80108bfc <switchuvm>
80104d10:	83 c4 10             	add    $0x10,%esp
      statelist_move_from_to(RUNNABLE, RUNNING, p);
80104d13:	83 ec 04             	sub    $0x4,%esp
80104d16:	ff 75 f0             	pushl  -0x10(%ebp)
80104d19:	6a 04                	push   $0x4
80104d1b:	6a 03                	push   $0x3
80104d1d:	e8 a1 09 00 00       	call   801056c3 <statelist_move_from_to>
80104d22:	83 c4 10             	add    $0x10,%esp
      //p->state = RUNNING;
      #ifdef CS333_P2
      p->cpu_ticks_in = ticks;
80104d25:	8b 15 00 67 11 80    	mov    0x80116700,%edx
80104d2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d2e:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      #endif
      swtch(&cpu->scheduler, proc->context);
80104d34:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d3a:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d3d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d44:	83 c2 04             	add    $0x4,%edx
80104d47:	83 ec 08             	sub    $0x8,%esp
80104d4a:	50                   	push   %eax
80104d4b:	52                   	push   %edx
80104d4c:	e8 3a 14 00 00       	call   8010618b <swtch>
80104d51:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104d54:	e8 86 3e 00 00       	call   80108bdf <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104d59:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d60:	00 00 00 00 
    }
    release(&ptable.lock);
80104d64:	83 ec 0c             	sub    $0xc,%esp
80104d67:	68 80 39 11 80       	push   $0x80113980
80104d6c:	e8 aa 0f 00 00       	call   80105d1b <release>
80104d71:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
80104d74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104d78:	0f 84 4d ff ff ff    	je     80104ccb <scheduler+0x6>
      sti();
80104d7e:	e8 84 f7 ff ff       	call   80104507 <sti>
      hlt();
80104d83:	e8 68 f7 ff ff       	call   801044f0 <hlt>
    }
  }
80104d88:	e9 3e ff ff ff       	jmp    80104ccb <scheduler+0x6>

80104d8d <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d8d:	55                   	push   %ebp
80104d8e:	89 e5                	mov    %esp,%ebp
80104d90:	53                   	push   %ebx
80104d91:	83 ec 14             	sub    $0x14,%esp
  int intena;

//cprintf("entering sched()\n");
  if(!holding(&ptable.lock))
80104d94:	83 ec 0c             	sub    $0xc,%esp
80104d97:	68 80 39 11 80       	push   $0x80113980
80104d9c:	e8 46 10 00 00       	call   80105de7 <holding>
80104da1:	83 c4 10             	add    $0x10,%esp
80104da4:	85 c0                	test   %eax,%eax
80104da6:	75 0d                	jne    80104db5 <sched+0x28>
    panic("sched ptable.lock");
80104da8:	83 ec 0c             	sub    $0xc,%esp
80104dab:	68 c8 96 10 80       	push   $0x801096c8
80104db0:	e8 b1 b7 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104db5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104dbb:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104dc1:	83 f8 01             	cmp    $0x1,%eax
80104dc4:	74 0d                	je     80104dd3 <sched+0x46>
    panic("sched locks");
80104dc6:	83 ec 0c             	sub    $0xc,%esp
80104dc9:	68 da 96 10 80       	push   $0x801096da
80104dce:	e8 93 b7 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104dd3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd9:	8b 40 0c             	mov    0xc(%eax),%eax
80104ddc:	83 f8 04             	cmp    $0x4,%eax
80104ddf:	75 0d                	jne    80104dee <sched+0x61>
    panic("sched running");
80104de1:	83 ec 0c             	sub    $0xc,%esp
80104de4:	68 e6 96 10 80       	push   $0x801096e6
80104de9:	e8 78 b7 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104dee:	e8 04 f7 ff ff       	call   801044f7 <readeflags>
80104df3:	25 00 02 00 00       	and    $0x200,%eax
80104df8:	85 c0                	test   %eax,%eax
80104dfa:	74 0d                	je     80104e09 <sched+0x7c>
    panic("sched interruptible");
80104dfc:	83 ec 0c             	sub    $0xc,%esp
80104dff:	68 f4 96 10 80       	push   $0x801096f4
80104e04:	e8 5d b7 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104e09:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e0f:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104e15:	89 45 f4             	mov    %eax,-0xc(%ebp)
  #ifdef CS333_P2
  proc->cpu_ticks_total += ticks - proc->cpu_ticks_in;
80104e18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e1e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e25:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
80104e2b:	8b 1d 00 67 11 80    	mov    0x80116700,%ebx
80104e31:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e38:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80104e3e:	29 d3                	sub    %edx,%ebx
80104e40:	89 da                	mov    %ebx,%edx
80104e42:	01 ca                	add    %ecx,%edx
80104e44:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
  #endif
  swtch(&proc->context, cpu->scheduler);
80104e4a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e50:	8b 40 04             	mov    0x4(%eax),%eax
80104e53:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e5a:	83 c2 1c             	add    $0x1c,%edx
80104e5d:	83 ec 08             	sub    $0x8,%esp
80104e60:	50                   	push   %eax
80104e61:	52                   	push   %edx
80104e62:	e8 24 13 00 00       	call   8010618b <swtch>
80104e67:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104e6a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e70:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e73:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
//cprintf("leaving sched()\n");
}
80104e79:	90                   	nop
80104e7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e7d:	c9                   	leave  
80104e7e:	c3                   	ret    

80104e7f <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e7f:	55                   	push   %ebp
80104e80:	89 e5                	mov    %esp,%ebp
80104e82:	83 ec 08             	sub    $0x8,%esp
//cprintf("entering yield()\n");
  acquire(&ptable.lock);  //DOC: yieldlock
80104e85:	83 ec 0c             	sub    $0xc,%esp
80104e88:	68 80 39 11 80       	push   $0x80113980
80104e8d:	e8 22 0e 00 00       	call   80105cb4 <acquire>
80104e92:	83 c4 10             	add    $0x10,%esp
  #ifdef CS333_P3P4
    statelist_move_from_to(RUNNING, RUNNABLE, proc);
80104e95:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e9b:	83 ec 04             	sub    $0x4,%esp
80104e9e:	50                   	push   %eax
80104e9f:	6a 03                	push   $0x3
80104ea1:	6a 04                	push   $0x4
80104ea3:	e8 1b 08 00 00       	call   801056c3 <statelist_move_from_to>
80104ea8:	83 c4 10             	add    $0x10,%esp
  #else
    proc->state = RUNNABLE;
  #endif
  sched();
80104eab:	e8 dd fe ff ff       	call   80104d8d <sched>
  release(&ptable.lock);
80104eb0:	83 ec 0c             	sub    $0xc,%esp
80104eb3:	68 80 39 11 80       	push   $0x80113980
80104eb8:	e8 5e 0e 00 00       	call   80105d1b <release>
80104ebd:	83 c4 10             	add    $0x10,%esp
//cprintf("leaving yield()\n");
}
80104ec0:	90                   	nop
80104ec1:	c9                   	leave  
80104ec2:	c3                   	ret    

80104ec3 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ec3:	55                   	push   %ebp
80104ec4:	89 e5                	mov    %esp,%ebp
80104ec6:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104ec9:	83 ec 0c             	sub    $0xc,%esp
80104ecc:	68 80 39 11 80       	push   $0x80113980
80104ed1:	e8 45 0e 00 00       	call   80105d1b <release>
80104ed6:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104ed9:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104ede:	85 c0                	test   %eax,%eax
80104ee0:	74 24                	je     80104f06 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104ee2:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80104ee9:	00 00 00 
    iinit(ROOTDEV);
80104eec:	83 ec 0c             	sub    $0xc,%esp
80104eef:	6a 01                	push   $0x1
80104ef1:	e8 fa c7 ff ff       	call   801016f0 <iinit>
80104ef6:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104ef9:	83 ec 0c             	sub    $0xc,%esp
80104efc:	6a 01                	push   $0x1
80104efe:	e8 de e4 ff ff       	call   801033e1 <initlog>
80104f03:	83 c4 10             	add    $0x10,%esp
  }
  // Return to "caller", actually trapret (see allocproc).
}
80104f06:	90                   	nop
80104f07:	c9                   	leave  
80104f08:	c3                   	ret    

80104f09 <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80104f09:	55                   	push   %ebp
80104f0a:	89 e5                	mov    %esp,%ebp
80104f0c:	83 ec 08             	sub    $0x8,%esp
//cprintf("entering sleep()\n");
  if(proc == 0)
80104f0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f15:	85 c0                	test   %eax,%eax
80104f17:	75 0d                	jne    80104f26 <sleep+0x1d>
    panic("sleep\n");
80104f19:	83 ec 0c             	sub    $0xc,%esp
80104f1c:	68 08 97 10 80       	push   $0x80109708
80104f21:	e8 40 b6 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
80104f26:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104f2d:	74 24                	je     80104f53 <sleep+0x4a>
    acquire(&ptable.lock);
80104f2f:	83 ec 0c             	sub    $0xc,%esp
80104f32:	68 80 39 11 80       	push   $0x80113980
80104f37:	e8 78 0d 00 00       	call   80105cb4 <acquire>
80104f3c:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
80104f3f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f43:	74 0e                	je     80104f53 <sleep+0x4a>
80104f45:	83 ec 0c             	sub    $0xc,%esp
80104f48:	ff 75 0c             	pushl  0xc(%ebp)
80104f4b:	e8 cb 0d 00 00       	call   80105d1b <release>
80104f50:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104f53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f59:	8b 55 08             	mov    0x8(%ebp),%edx
80104f5c:	89 50 20             	mov    %edx,0x20(%eax)
  #ifdef CS333_P3P4
    statelist_move_from_to(RUNNING, SLEEPING, proc);
80104f5f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f65:	83 ec 04             	sub    $0x4,%esp
80104f68:	50                   	push   %eax
80104f69:	6a 02                	push   $0x2
80104f6b:	6a 04                	push   $0x4
80104f6d:	e8 51 07 00 00       	call   801056c3 <statelist_move_from_to>
80104f72:	83 c4 10             	add    $0x10,%esp
  #else
    proc->state = SLEEPING;
  #endif
  sched();
80104f75:	e8 13 fe ff ff       	call   80104d8d <sched>

  // Tidy up.
  proc->chan = 0;
80104f7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f80:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
80104f87:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104f8e:	74 24                	je     80104fb4 <sleep+0xab>
    release(&ptable.lock);
80104f90:	83 ec 0c             	sub    $0xc,%esp
80104f93:	68 80 39 11 80       	push   $0x80113980
80104f98:	e8 7e 0d 00 00       	call   80105d1b <release>
80104f9d:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80104fa0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104fa4:	74 0e                	je     80104fb4 <sleep+0xab>
80104fa6:	83 ec 0c             	sub    $0xc,%esp
80104fa9:	ff 75 0c             	pushl  0xc(%ebp)
80104fac:	e8 03 0d 00 00       	call   80105cb4 <acquire>
80104fb1:	83 c4 10             	add    $0x10,%esp
  }
//cprintf("leaving sleep()\n");
}
80104fb4:	90                   	nop
80104fb5:	c9                   	leave  
80104fb6:	c3                   	ret    

80104fb7 <wakeup1>:
      p->state = RUNNABLE;
}
#else
static void
wakeup1(void *chan)
{
80104fb7:	55                   	push   %ebp
80104fb8:	89 e5                	mov    %esp,%ebp
80104fba:	83 ec 18             	sub    $0x18,%esp

//cprintf("entering wakeup1()\n");
 struct proc * p = ptable.pLists.sleep;
80104fbd:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80104fc2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 struct proc * tmp;
 if (!holding(&ptable.lock))
80104fc5:	83 ec 0c             	sub    $0xc,%esp
80104fc8:	68 80 39 11 80       	push   $0x80113980
80104fcd:	e8 15 0e 00 00       	call   80105de7 <holding>
80104fd2:	83 c4 10             	add    $0x10,%esp
80104fd5:	85 c0                	test   %eax,%eax
80104fd7:	75 3c                	jne    80105015 <wakeup1+0x5e>
   panic("not holding ptable.lock in wakeup1() (proc.c)\n");
80104fd9:	83 ec 0c             	sub    $0xc,%esp
80104fdc:	68 10 97 10 80       	push   $0x80109710
80104fe1:	e8 80 b5 ff ff       	call   80100566 <panic>

 while (p) {
   tmp = p;
80104fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe9:	89 45 f0             	mov    %eax,-0x10(%ebp)
   p = p->next;
80104fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fef:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80104ff5:	89 45 f4             	mov    %eax,-0xc(%ebp)
   if (tmp->chan == chan)
80104ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ffb:	8b 40 20             	mov    0x20(%eax),%eax
80104ffe:	3b 45 08             	cmp    0x8(%ebp),%eax
80105001:	75 12                	jne    80105015 <wakeup1+0x5e>
     statelist_move_from_to(SLEEPING, RUNNABLE, tmp);
80105003:	83 ec 04             	sub    $0x4,%esp
80105006:	ff 75 f0             	pushl  -0x10(%ebp)
80105009:	6a 03                	push   $0x3
8010500b:	6a 02                	push   $0x2
8010500d:	e8 b1 06 00 00       	call   801056c3 <statelist_move_from_to>
80105012:	83 c4 10             	add    $0x10,%esp
 struct proc * p = ptable.pLists.sleep;
 struct proc * tmp;
 if (!holding(&ptable.lock))
   panic("not holding ptable.lock in wakeup1() (proc.c)\n");

 while (p) {
80105015:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105019:	75 cb                	jne    80104fe6 <wakeup1+0x2f>
   p = p->next;
   if (tmp->chan == chan)
     statelist_move_from_to(SLEEPING, RUNNABLE, tmp);
  }
//cprintf("leaving wakeup1()\n");
}
8010501b:	90                   	nop
8010501c:	c9                   	leave  
8010501d:	c3                   	ret    

8010501e <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010501e:	55                   	push   %ebp
8010501f:	89 e5                	mov    %esp,%ebp
80105021:	83 ec 08             	sub    $0x8,%esp
//cprintf("entering wakeup()\n");
  acquire(&ptable.lock);
80105024:	83 ec 0c             	sub    $0xc,%esp
80105027:	68 80 39 11 80       	push   $0x80113980
8010502c:	e8 83 0c 00 00       	call   80105cb4 <acquire>
80105031:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105034:	83 ec 0c             	sub    $0xc,%esp
80105037:	ff 75 08             	pushl  0x8(%ebp)
8010503a:	e8 78 ff ff ff       	call   80104fb7 <wakeup1>
8010503f:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105042:	83 ec 0c             	sub    $0xc,%esp
80105045:	68 80 39 11 80       	push   $0x80113980
8010504a:	e8 cc 0c 00 00       	call   80105d1b <release>
8010504f:	83 c4 10             	add    $0x10,%esp
//cprintf("leaving wakeup()\n");
}
80105052:	90                   	nop
80105053:	c9                   	leave  
80105054:	c3                   	ret    

80105055 <kill>:
  return -1;
}
#else
int
kill(int pid)
{
80105055:	55                   	push   %ebp
80105056:	89 e5                	mov    %esp,%ebp
80105058:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
8010505b:	83 ec 0c             	sub    $0xc,%esp
8010505e:	68 80 39 11 80       	push   $0x80113980
80105063:	e8 4c 0c 00 00       	call   80105cb4 <acquire>
80105068:	83 c4 10             	add    $0x10,%esp

  p = statelist_search(pid);
8010506b:	83 ec 0c             	sub    $0xc,%esp
8010506e:	ff 75 08             	pushl  0x8(%ebp)
80105071:	e8 cb 07 00 00       	call   80105841 <statelist_search>
80105076:	83 c4 10             	add    $0x10,%esp
80105079:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(p){
8010507c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105080:	74 3e                	je     801050c0 <kill+0x6b>
    p->killed = 1;
80105082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105085:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
    // Wake process from sleep if necessary.
    if(p->state == SLEEPING)
8010508c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010508f:	8b 40 0c             	mov    0xc(%eax),%eax
80105092:	83 f8 02             	cmp    $0x2,%eax
80105095:	75 12                	jne    801050a9 <kill+0x54>
      statelist_move_from_to(SLEEPING, RUNNABLE, p);
80105097:	83 ec 04             	sub    $0x4,%esp
8010509a:	ff 75 f4             	pushl  -0xc(%ebp)
8010509d:	6a 03                	push   $0x3
8010509f:	6a 02                	push   $0x2
801050a1:	e8 1d 06 00 00       	call   801056c3 <statelist_move_from_to>
801050a6:	83 c4 10             	add    $0x10,%esp
    release(&ptable.lock);
801050a9:	83 ec 0c             	sub    $0xc,%esp
801050ac:	68 80 39 11 80       	push   $0x80113980
801050b1:	e8 65 0c 00 00       	call   80105d1b <release>
801050b6:	83 c4 10             	add    $0x10,%esp
    return 0;
801050b9:	b8 00 00 00 00       	mov    $0x0,%eax
801050be:	eb 15                	jmp    801050d5 <kill+0x80>
  }

  release(&ptable.lock);
801050c0:	83 ec 0c             	sub    $0xc,%esp
801050c3:	68 80 39 11 80       	push   $0x80113980
801050c8:	e8 4e 0c 00 00       	call   80105d1b <release>
801050cd:	83 c4 10             	add    $0x10,%esp

  return -1;
801050d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050d5:	c9                   	leave  
801050d6:	c3                   	ret    

801050d7 <print_millisec>:
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
#ifdef CS333_P1
void
print_millisec(uint millisec)
{
801050d7:	55                   	push   %ebp
801050d8:	89 e5                	mov    %esp,%ebp
801050da:	83 ec 08             	sub    $0x8,%esp
  cprintf("%d.", millisec /1000);
801050dd:	8b 45 08             	mov    0x8(%ebp),%eax
801050e0:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
801050e5:	f7 e2                	mul    %edx
801050e7:	89 d0                	mov    %edx,%eax
801050e9:	c1 e8 06             	shr    $0x6,%eax
801050ec:	83 ec 08             	sub    $0x8,%esp
801050ef:	50                   	push   %eax
801050f0:	68 69 97 10 80       	push   $0x80109769
801050f5:	e8 cc b2 ff ff       	call   801003c6 <cprintf>
801050fa:	83 c4 10             	add    $0x10,%esp

  millisec %= 1000;
801050fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105100:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80105105:	89 c8                	mov    %ecx,%eax
80105107:	f7 e2                	mul    %edx
80105109:	89 d0                	mov    %edx,%eax
8010510b:	c1 e8 06             	shr    $0x6,%eax
8010510e:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80105114:	29 c1                	sub    %eax,%ecx
80105116:	89 c8                	mov    %ecx,%eax
80105118:	89 45 08             	mov    %eax,0x8(%ebp)
  if (millisec < 100)
8010511b:	83 7d 08 63          	cmpl   $0x63,0x8(%ebp)
8010511f:	77 10                	ja     80105131 <print_millisec+0x5a>
    cprintf("0");
80105121:	83 ec 0c             	sub    $0xc,%esp
80105124:	68 6d 97 10 80       	push   $0x8010976d
80105129:	e8 98 b2 ff ff       	call   801003c6 <cprintf>
8010512e:	83 c4 10             	add    $0x10,%esp
  if (millisec < 10)
80105131:	83 7d 08 09          	cmpl   $0x9,0x8(%ebp)
80105135:	77 10                	ja     80105147 <print_millisec+0x70>
    cprintf("0");
80105137:	83 ec 0c             	sub    $0xc,%esp
8010513a:	68 6d 97 10 80       	push   $0x8010976d
8010513f:	e8 82 b2 ff ff       	call   801003c6 <cprintf>
80105144:	83 c4 10             	add    $0x10,%esp

  cprintf("%d\t", millisec);
80105147:	83 ec 08             	sub    $0x8,%esp
8010514a:	ff 75 08             	pushl  0x8(%ebp)
8010514d:	68 6f 97 10 80       	push   $0x8010976f
80105152:	e8 6f b2 ff ff       	call   801003c6 <cprintf>
80105157:	83 c4 10             	add    $0x10,%esp
}
8010515a:	90                   	nop
8010515b:	c9                   	leave  
8010515c:	c3                   	ret    

8010515d <getprocs>:
#endif

#ifdef CS333_P2
int
getprocs(uint max, struct uproc* table)
{
8010515d:	55                   	push   %ebp
8010515e:	89 e5                	mov    %esp,%ebp
80105160:	83 ec 18             	sub    $0x18,%esp
  int num_uprocs, lock = 0;
80105163:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  struct proc* begin, * end;
  if (!table || max < 1)
8010516a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010516e:	74 06                	je     80105176 <getprocs+0x19>
80105170:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105174:	75 0a                	jne    80105180 <getprocs+0x23>
    return -1;
80105176:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010517b:	e9 8e 01 00 00       	jmp    8010530e <getprocs+0x1b1>

  if (!holding(&ptable.lock)) {
80105180:	83 ec 0c             	sub    $0xc,%esp
80105183:	68 80 39 11 80       	push   $0x80113980
80105188:	e8 5a 0c 00 00       	call   80105de7 <holding>
8010518d:	83 c4 10             	add    $0x10,%esp
80105190:	85 c0                	test   %eax,%eax
80105192:	75 17                	jne    801051ab <getprocs+0x4e>
    acquire(&ptable.lock);
80105194:	83 ec 0c             	sub    $0xc,%esp
80105197:	68 80 39 11 80       	push   $0x80113980
8010519c:	e8 13 0b 00 00       	call   80105cb4 <acquire>
801051a1:	83 c4 10             	add    $0x10,%esp
    lock = 1;
801051a4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  }

  begin = ptable.proc;
801051ab:	c7 45 ec b4 39 11 80 	movl   $0x801139b4,-0x14(%ebp)
  end = ptable.proc + NPROC;
801051b2:	c7 45 e8 b4 5e 11 80 	movl   $0x80115eb4,-0x18(%ebp)
  num_uprocs = 0;
801051b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  while (begin < end && num_uprocs < max) {
801051c0:	e9 1c 01 00 00       	jmp    801052e1 <getprocs+0x184>
    if (begin->state == EMBRYO || begin->state == UNUSED) {
801051c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051c8:	8b 40 0c             	mov    0xc(%eax),%eax
801051cb:	83 f8 01             	cmp    $0x1,%eax
801051ce:	74 0a                	je     801051da <getprocs+0x7d>
801051d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051d3:	8b 40 0c             	mov    0xc(%eax),%eax
801051d6:	85 c0                	test   %eax,%eax
801051d8:	75 0c                	jne    801051e6 <getprocs+0x89>
      ++begin;
801051da:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
      continue;
801051e1:	e9 fb 00 00 00       	jmp    801052e1 <getprocs+0x184>
    }
    table->pid = begin->pid;
801051e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051e9:	8b 50 10             	mov    0x10(%eax),%edx
801051ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801051ef:	89 10                	mov    %edx,(%eax)
    table->uid = begin->uid;
801051f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051f4:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801051fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801051fd:	89 50 04             	mov    %edx,0x4(%eax)
    table->gid = begin->gid;
80105200:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105203:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80105209:	8b 45 0c             	mov    0xc(%ebp),%eax
8010520c:	89 50 08             	mov    %edx,0x8(%eax)
    table->ppid = (begin->parent) ? begin->parent->pid : begin->pid;
8010520f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105212:	8b 40 14             	mov    0x14(%eax),%eax
80105215:	85 c0                	test   %eax,%eax
80105217:	74 0b                	je     80105224 <getprocs+0xc7>
80105219:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010521c:	8b 40 14             	mov    0x14(%eax),%eax
8010521f:	8b 40 10             	mov    0x10(%eax),%eax
80105222:	eb 06                	jmp    8010522a <getprocs+0xcd>
80105224:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105227:	8b 40 10             	mov    0x10(%eax),%eax
8010522a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010522d:	89 42 0c             	mov    %eax,0xc(%edx)
    table->elapsed_ticks = ticks - begin->start_ticks;
80105230:	8b 15 00 67 11 80    	mov    0x80116700,%edx
80105236:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105239:	8b 40 7c             	mov    0x7c(%eax),%eax
8010523c:	29 c2                	sub    %eax,%edx
8010523e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105241:	89 50 10             	mov    %edx,0x10(%eax)
    table->CPU_total_ticks = begin->cpu_ticks_total;
80105244:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105247:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
8010524d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105250:	89 50 14             	mov    %edx,0x14(%eax)
    if(begin->state >= 0 && begin->state < NELEM(states) && states[begin->state])
80105253:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105256:	8b 40 0c             	mov    0xc(%eax),%eax
80105259:	83 f8 05             	cmp    $0x5,%eax
8010525c:	77 35                	ja     80105293 <getprocs+0x136>
8010525e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105261:	8b 40 0c             	mov    0xc(%eax),%eax
80105264:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010526b:	85 c0                	test   %eax,%eax
8010526d:	74 24                	je     80105293 <getprocs+0x136>
      safestrcpy(table->state, states[begin->state], sizeof(table->name));
8010526f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105272:	8b 40 0c             	mov    0xc(%eax),%eax
80105275:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010527c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010527f:	83 c2 18             	add    $0x18,%edx
80105282:	83 ec 04             	sub    $0x4,%esp
80105285:	6a 20                	push   $0x20
80105287:	50                   	push   %eax
80105288:	52                   	push   %edx
80105289:	e8 8c 0e 00 00       	call   8010611a <safestrcpy>
8010528e:	83 c4 10             	add    $0x10,%esp
80105291:	eb 19                	jmp    801052ac <getprocs+0x14f>
    else
      safestrcpy(table->state, "???", sizeof(table->name));
80105293:	8b 45 0c             	mov    0xc(%ebp),%eax
80105296:	83 c0 18             	add    $0x18,%eax
80105299:	83 ec 04             	sub    $0x4,%esp
8010529c:	6a 20                	push   $0x20
8010529e:	68 73 97 10 80       	push   $0x80109773
801052a3:	50                   	push   %eax
801052a4:	e8 71 0e 00 00       	call   8010611a <safestrcpy>
801052a9:	83 c4 10             	add    $0x10,%esp
    table->size = begin->sz;
801052ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052af:	8b 10                	mov    (%eax),%edx
801052b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052b4:	89 50 38             	mov    %edx,0x38(%eax)
    safestrcpy(table->name, begin->name, sizeof(table->name));
801052b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052ba:	8d 50 6c             	lea    0x6c(%eax),%edx
801052bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c0:	83 c0 3c             	add    $0x3c,%eax
801052c3:	83 ec 04             	sub    $0x4,%esp
801052c6:	6a 20                	push   $0x20
801052c8:	52                   	push   %edx
801052c9:	50                   	push   %eax
801052ca:	e8 4b 0e 00 00       	call   8010611a <safestrcpy>
801052cf:	83 c4 10             	add    $0x10,%esp
    ++begin; ++table; ++num_uprocs;
801052d2:	81 45 ec 94 00 00 00 	addl   $0x94,-0x14(%ebp)
801052d9:	83 45 0c 5c          	addl   $0x5c,0xc(%ebp)
801052dd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  begin = ptable.proc;
  end = ptable.proc + NPROC;
  num_uprocs = 0;

  while (begin < end && num_uprocs < max) {
801052e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052e4:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801052e7:	73 0c                	jae    801052f5 <getprocs+0x198>
801052e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ec:	3b 45 08             	cmp    0x8(%ebp),%eax
801052ef:	0f 82 d0 fe ff ff    	jb     801051c5 <getprocs+0x68>
    table->size = begin->sz;
    safestrcpy(table->name, begin->name, sizeof(table->name));
    ++begin; ++table; ++num_uprocs;
  }

  if (lock)
801052f5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052f9:	74 10                	je     8010530b <getprocs+0x1ae>
    release(&ptable.lock);
801052fb:	83 ec 0c             	sub    $0xc,%esp
801052fe:	68 80 39 11 80       	push   $0x80113980
80105303:	e8 13 0a 00 00       	call   80105d1b <release>
80105308:	83 c4 10             	add    $0x10,%esp

  return num_uprocs;
8010530b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010530e:	c9                   	leave  
8010530f:	c3                   	ret    

80105310 <procdump>:
#endif

void
procdump(void)
{
80105310:	55                   	push   %ebp
80105311:	89 e5                	mov    %esp,%ebp
80105313:	53                   	push   %ebx
80105314:	83 ec 44             	sub    $0x44,%esp
  uint pc[10];
  #ifdef CS333_P2
  uint ppid;

    #ifdef CS333_P3P4
    cprintf("NPROC = %d\n", NPROC);
80105317:	83 ec 08             	sub    $0x8,%esp
8010531a:	6a 40                	push   $0x40
8010531c:	68 77 97 10 80       	push   $0x80109777
80105321:	e8 a0 b0 ff ff       	call   801003c6 <cprintf>
80105326:	83 c4 10             	add    $0x10,%esp
    #endif
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
80105329:	83 ec 0c             	sub    $0xc,%esp
8010532c:	68 84 97 10 80       	push   $0x80109784
80105331:	e8 90 b0 ff ff       	call   801003c6 <cprintf>
80105336:	83 c4 10             	add    $0x10,%esp
  #elif defined(CS333_P1)
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
  #endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105339:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80105340:	e9 59 01 00 00       	jmp    8010549e <procdump+0x18e>
    if(p->state == UNUSED)
80105345:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105348:	8b 40 0c             	mov    0xc(%eax),%eax
8010534b:	85 c0                	test   %eax,%eax
8010534d:	0f 84 43 01 00 00    	je     80105496 <procdump+0x186>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105353:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105356:	8b 40 0c             	mov    0xc(%eax),%eax
80105359:	83 f8 05             	cmp    $0x5,%eax
8010535c:	77 23                	ja     80105381 <procdump+0x71>
8010535e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105361:	8b 40 0c             	mov    0xc(%eax),%eax
80105364:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010536b:	85 c0                	test   %eax,%eax
8010536d:	74 12                	je     80105381 <procdump+0x71>
      state = states[p->state];
8010536f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105372:	8b 40 0c             	mov    0xc(%eax),%eax
80105375:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010537c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010537f:	eb 07                	jmp    80105388 <procdump+0x78>
    else
      state = "???";
80105381:	c7 45 ec 73 97 10 80 	movl   $0x80109773,-0x14(%ebp)
    #ifndef CS333_P1 
    cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
    #endif
    #ifdef CS333_P1
        #ifdef CS333_P2
          ppid = p->parent ? p->parent->pid : p->pid;
80105388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010538b:	8b 40 14             	mov    0x14(%eax),%eax
8010538e:	85 c0                	test   %eax,%eax
80105390:	74 0b                	je     8010539d <procdump+0x8d>
80105392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105395:	8b 40 14             	mov    0x14(%eax),%eax
80105398:	8b 40 10             	mov    0x10(%eax),%eax
8010539b:	eb 06                	jmp    801053a3 <procdump+0x93>
8010539d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a0:	8b 40 10             	mov    0x10(%eax),%eax
801053a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
          cprintf("%d\t%s\t%d\t%d\t%d\t", 
801053a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a9:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
801053af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b2:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
              p->pid, p->name, p->uid, p->gid, ppid);
801053b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053bb:	8d 58 6c             	lea    0x6c(%eax),%ebx
    cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
    #endif
    #ifdef CS333_P1
        #ifdef CS333_P2
          ppid = p->parent ? p->parent->pid : p->pid;
          cprintf("%d\t%s\t%d\t%d\t%d\t", 
801053be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053c1:	8b 40 10             	mov    0x10(%eax),%eax
801053c4:	83 ec 08             	sub    $0x8,%esp
801053c7:	ff 75 e8             	pushl  -0x18(%ebp)
801053ca:	51                   	push   %ecx
801053cb:	52                   	push   %edx
801053cc:	53                   	push   %ebx
801053cd:	50                   	push   %eax
801053ce:	68 b8 97 10 80       	push   $0x801097b8
801053d3:	e8 ee af ff ff       	call   801003c6 <cprintf>
801053d8:	83 c4 20             	add    $0x20,%esp
              p->pid, p->name, p->uid, p->gid, ppid);
        #else
          cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
        #endif
    // display elapsed time
      print_millisec(ticks - p->start_ticks);
801053db:	8b 15 00 67 11 80    	mov    0x80116700,%edx
801053e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e4:	8b 40 7c             	mov    0x7c(%eax),%eax
801053e7:	29 c2                	sub    %eax,%edx
801053e9:	89 d0                	mov    %edx,%eax
801053eb:	83 ec 0c             	sub    $0xc,%esp
801053ee:	50                   	push   %eax
801053ef:	e8 e3 fc ff ff       	call   801050d7 <print_millisec>
801053f4:	83 c4 10             	add    $0x10,%esp
        #ifdef CS333_P2
          print_millisec(p->cpu_ticks_total);
801053f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053fa:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105400:	83 ec 0c             	sub    $0xc,%esp
80105403:	50                   	push   %eax
80105404:	e8 ce fc ff ff       	call   801050d7 <print_millisec>
80105409:	83 c4 10             	add    $0x10,%esp
          cprintf("%s\t%d\t",state,p->sz);
8010540c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540f:	8b 00                	mov    (%eax),%eax
80105411:	83 ec 04             	sub    $0x4,%esp
80105414:	50                   	push   %eax
80105415:	ff 75 ec             	pushl  -0x14(%ebp)
80105418:	68 c8 97 10 80       	push   $0x801097c8
8010541d:	e8 a4 af ff ff       	call   801003c6 <cprintf>
80105422:	83 c4 10             	add    $0x10,%esp
        #endif // CS333_P2
    #endif // CS333_p1

    if(p->state == SLEEPING){
80105425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105428:	8b 40 0c             	mov    0xc(%eax),%eax
8010542b:	83 f8 02             	cmp    $0x2,%eax
8010542e:	75 54                	jne    80105484 <procdump+0x174>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105433:	8b 40 1c             	mov    0x1c(%eax),%eax
80105436:	8b 40 0c             	mov    0xc(%eax),%eax
80105439:	83 c0 08             	add    $0x8,%eax
8010543c:	89 c2                	mov    %eax,%edx
8010543e:	83 ec 08             	sub    $0x8,%esp
80105441:	8d 45 c0             	lea    -0x40(%ebp),%eax
80105444:	50                   	push   %eax
80105445:	52                   	push   %edx
80105446:	e8 22 09 00 00       	call   80105d6d <getcallerpcs>
8010544b:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
8010544e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105455:	eb 1c                	jmp    80105473 <procdump+0x163>
        cprintf(" %p", pc[i]);
80105457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010545a:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
8010545e:	83 ec 08             	sub    $0x8,%esp
80105461:	50                   	push   %eax
80105462:	68 cf 97 10 80       	push   $0x801097cf
80105467:	e8 5a af ff ff       	call   801003c6 <cprintf>
8010546c:	83 c4 10             	add    $0x10,%esp
        #endif // CS333_P2
    #endif // CS333_p1

    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010546f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105473:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105477:	7f 0b                	jg     80105484 <procdump+0x174>
80105479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010547c:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105480:	85 c0                	test   %eax,%eax
80105482:	75 d3                	jne    80105457 <procdump+0x147>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105484:	83 ec 0c             	sub    $0xc,%esp
80105487:	68 d3 97 10 80       	push   $0x801097d3
8010548c:	e8 35 af ff ff       	call   801003c6 <cprintf>
80105491:	83 c4 10             	add    $0x10,%esp
80105494:	eb 01                	jmp    80105497 <procdump+0x187>
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
  #endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105496:	90                   	nop
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
  #elif defined(CS333_P1)
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
  #endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105497:	81 45 f0 94 00 00 00 	addl   $0x94,-0x10(%ebp)
8010549e:	81 7d f0 b4 5e 11 80 	cmpl   $0x80115eb4,-0x10(%ebp)
801054a5:	0f 82 9a fe ff ff    	jb     80105345 <procdump+0x35>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
801054ab:	90                   	nop
801054ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801054af:	c9                   	leave  
801054b0:	c3                   	ret    

801054b1 <stateListAdd>:


#ifdef CS333_P3P4
static int
stateListAdd(struct proc** head, struct proc** tail, struct proc* p)
{
801054b1:	55                   	push   %ebp
801054b2:	89 e5                	mov    %esp,%ebp
  if (*head == 0) {
801054b4:	8b 45 08             	mov    0x8(%ebp),%eax
801054b7:	8b 00                	mov    (%eax),%eax
801054b9:	85 c0                	test   %eax,%eax
801054bb:	75 1f                	jne    801054dc <stateListAdd+0x2b>
    *head = p;
801054bd:	8b 45 08             	mov    0x8(%ebp),%eax
801054c0:	8b 55 10             	mov    0x10(%ebp),%edx
801054c3:	89 10                	mov    %edx,(%eax)
    *tail = p;
801054c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801054c8:	8b 55 10             	mov    0x10(%ebp),%edx
801054cb:	89 10                	mov    %edx,(%eax)
    p->next = 0;
801054cd:	8b 45 10             	mov    0x10(%ebp),%eax
801054d0:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801054d7:	00 00 00 
801054da:	eb 2d                	jmp    80105509 <stateListAdd+0x58>
  } else {
    (*tail)->next = p;
801054dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801054df:	8b 00                	mov    (%eax),%eax
801054e1:	8b 55 10             	mov    0x10(%ebp),%edx
801054e4:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
    *tail = (*tail)->next;
801054ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801054ed:	8b 00                	mov    (%eax),%eax
801054ef:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801054f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801054f8:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
801054fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801054fd:	8b 00                	mov    (%eax),%eax
801054ff:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
80105506:	00 00 00 
  }

  return 0;
80105509:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010550e:	5d                   	pop    %ebp
8010550f:	c3                   	ret    

80105510 <stateListRemove>:

static int
stateListRemove(struct proc** head, struct proc** tail, struct proc* p)
{
80105510:	55                   	push   %ebp
80105511:	89 e5                	mov    %esp,%ebp
80105513:	83 ec 10             	sub    $0x10,%esp
  if (*head == 0 || *tail == 0 || p == 0) {
80105516:	8b 45 08             	mov    0x8(%ebp),%eax
80105519:	8b 00                	mov    (%eax),%eax
8010551b:	85 c0                	test   %eax,%eax
8010551d:	74 0f                	je     8010552e <stateListRemove+0x1e>
8010551f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105522:	8b 00                	mov    (%eax),%eax
80105524:	85 c0                	test   %eax,%eax
80105526:	74 06                	je     8010552e <stateListRemove+0x1e>
80105528:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010552c:	75 0a                	jne    80105538 <stateListRemove+0x28>
    return -1;
8010552e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105533:	e9 a5 00 00 00       	jmp    801055dd <stateListRemove+0xcd>
  }

  struct proc* current = *head;
80105538:	8b 45 08             	mov    0x8(%ebp),%eax
8010553b:	8b 00                	mov    (%eax),%eax
8010553d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct proc* previous = 0;
80105540:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

  if (current == p) {
80105547:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010554a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010554d:	75 31                	jne    80105580 <stateListRemove+0x70>
    *head = (*head)->next;
8010554f:	8b 45 08             	mov    0x8(%ebp),%eax
80105552:	8b 00                	mov    (%eax),%eax
80105554:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
8010555a:	8b 45 08             	mov    0x8(%ebp),%eax
8010555d:	89 10                	mov    %edx,(%eax)
    return 0;
8010555f:	b8 00 00 00 00       	mov    $0x0,%eax
80105564:	eb 77                	jmp    801055dd <stateListRemove+0xcd>
  }

  while(current) {
    if (current == p) {
80105566:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105569:	3b 45 10             	cmp    0x10(%ebp),%eax
8010556c:	74 1a                	je     80105588 <stateListRemove+0x78>
      break;
    }

    previous = current;
8010556e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105571:	89 45 f8             	mov    %eax,-0x8(%ebp)
    current = current->next;
80105574:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105577:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
8010557d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if (current == p) {
    *head = (*head)->next;
    return 0;
  }

  while(current) {
80105580:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105584:	75 e0                	jne    80105566 <stateListRemove+0x56>
80105586:	eb 01                	jmp    80105589 <stateListRemove+0x79>
    if (current == p) {
      break;
80105588:	90                   	nop
    previous = current;
    current = current->next;
  }

  // Process not found, hit eject.
  if (current == 0) {
80105589:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010558d:	75 07                	jne    80105596 <stateListRemove+0x86>
    return -1;
8010558f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105594:	eb 47                	jmp    801055dd <stateListRemove+0xcd>
  }

  // Process found. Set the appropriate next pointer.
  if (current == *tail) {
80105596:	8b 45 0c             	mov    0xc(%ebp),%eax
80105599:	8b 00                	mov    (%eax),%eax
8010559b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
8010559e:	75 19                	jne    801055b9 <stateListRemove+0xa9>
    *tail = previous;
801055a0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a3:	8b 55 f8             	mov    -0x8(%ebp),%edx
801055a6:	89 10                	mov    %edx,(%eax)
    (*tail)->next = 0;
801055a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ab:	8b 00                	mov    (%eax),%eax
801055ad:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801055b4:	00 00 00 
801055b7:	eb 12                	jmp    801055cb <stateListRemove+0xbb>
  } else {
    previous->next = current->next;
801055b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055bc:	8b 90 90 00 00 00    	mov    0x90(%eax),%edx
801055c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055c5:	89 90 90 00 00 00    	mov    %edx,0x90(%eax)
  }

  // Make sure p->next doesn't point into the list.
  p->next = 0;
801055cb:	8b 45 10             	mov    0x10(%ebp),%eax
801055ce:	c7 80 90 00 00 00 00 	movl   $0x0,0x90(%eax)
801055d5:	00 00 00 

  return 0;
801055d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055dd:	c9                   	leave  
801055de:	c3                   	ret    

801055df <initProcessLists>:

static void
initProcessLists(void) {
801055df:	55                   	push   %ebp
801055e0:	89 e5                	mov    %esp,%ebp
  ptable.pLists.ready = 0;
801055e2:	c7 05 b4 5e 11 80 00 	movl   $0x0,0x80115eb4
801055e9:	00 00 00 
  ptable.pLists.readyTail = 0;
801055ec:	c7 05 b8 5e 11 80 00 	movl   $0x0,0x80115eb8
801055f3:	00 00 00 
  ptable.pLists.free = 0;
801055f6:	c7 05 bc 5e 11 80 00 	movl   $0x0,0x80115ebc
801055fd:	00 00 00 
  ptable.pLists.freeTail = 0;
80105600:	c7 05 c0 5e 11 80 00 	movl   $0x0,0x80115ec0
80105607:	00 00 00 
  ptable.pLists.sleep = 0;
8010560a:	c7 05 c4 5e 11 80 00 	movl   $0x0,0x80115ec4
80105611:	00 00 00 
  ptable.pLists.sleepTail = 0;
80105614:	c7 05 c8 5e 11 80 00 	movl   $0x0,0x80115ec8
8010561b:	00 00 00 
  ptable.pLists.zombie = 0;
8010561e:	c7 05 cc 5e 11 80 00 	movl   $0x0,0x80115ecc
80105625:	00 00 00 
  ptable.pLists.zombieTail = 0;
80105628:	c7 05 d0 5e 11 80 00 	movl   $0x0,0x80115ed0
8010562f:	00 00 00 
  ptable.pLists.running = 0;
80105632:	c7 05 d4 5e 11 80 00 	movl   $0x0,0x80115ed4
80105639:	00 00 00 
  ptable.pLists.runningTail = 0;
8010563c:	c7 05 d8 5e 11 80 00 	movl   $0x0,0x80115ed8
80105643:	00 00 00 
  ptable.pLists.embryo = 0;
80105646:	c7 05 dc 5e 11 80 00 	movl   $0x0,0x80115edc
8010564d:	00 00 00 
  ptable.pLists.embryoTail = 0;
80105650:	c7 05 e0 5e 11 80 00 	movl   $0x0,0x80115ee0
80105657:	00 00 00 
}
8010565a:	90                   	nop
8010565b:	5d                   	pop    %ebp
8010565c:	c3                   	ret    

8010565d <initFreeList>:

static void
initFreeList(void) {
8010565d:	55                   	push   %ebp
8010565e:	89 e5                	mov    %esp,%ebp
80105660:	83 ec 18             	sub    $0x18,%esp
  if (!holding(&ptable.lock)) {
80105663:	83 ec 0c             	sub    $0xc,%esp
80105666:	68 80 39 11 80       	push   $0x80113980
8010566b:	e8 77 07 00 00       	call   80105de7 <holding>
80105670:	83 c4 10             	add    $0x10,%esp
80105673:	85 c0                	test   %eax,%eax
80105675:	75 0d                	jne    80105684 <initFreeList+0x27>
    panic("acquire the ptable lock before calling initFreeList\n");
80105677:	83 ec 0c             	sub    $0xc,%esp
8010567a:	68 d8 97 10 80       	push   $0x801097d8
8010567f:	e8 e2 ae ff ff       	call   80100566 <panic>
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
80105684:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
8010568b:	eb 29                	jmp    801056b6 <initFreeList+0x59>
    p->state = UNUSED;
8010568d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105690:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
80105697:	83 ec 04             	sub    $0x4,%esp
8010569a:	ff 75 f4             	pushl  -0xc(%ebp)
8010569d:	68 c0 5e 11 80       	push   $0x80115ec0
801056a2:	68 bc 5e 11 80       	push   $0x80115ebc
801056a7:	e8 05 fe ff ff       	call   801054b1 <stateListAdd>
801056ac:	83 c4 10             	add    $0x10,%esp
    panic("acquire the ptable lock before calling initFreeList\n");
  }

  struct proc* p;

  for (p = ptable.proc; p < ptable.proc + NPROC; ++p) {
801056af:	81 45 f4 94 00 00 00 	addl   $0x94,-0xc(%ebp)
801056b6:	b8 b4 5e 11 80       	mov    $0x80115eb4,%eax
801056bb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801056be:	72 cd                	jb     8010568d <initFreeList+0x30>
    p->state = UNUSED;
    stateListAdd(&ptable.pLists.free, &ptable.pLists.freeTail, p);
  }
}
801056c0:	90                   	nop
801056c1:	c9                   	leave  
801056c2:	c3                   	ret    

801056c3 <statelist_move_from_to>:

// Student added helpers:
static void
statelist_move_from_to(enum procstate state_from, enum procstate state_to, struct proc* p) {
801056c3:	55                   	push   %ebp
801056c4:	89 e5                	mov    %esp,%ebp
801056c6:	83 ec 18             	sub    $0x18,%esp
  if (!p) return;
801056c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801056cd:	0f 84 c4 00 00 00    	je     80105797 <statelist_move_from_to+0xd4>
  int lock = holding(&ptable.lock);
801056d3:	83 ec 0c             	sub    $0xc,%esp
801056d6:	68 80 39 11 80       	push   $0x80113980
801056db:	e8 07 07 00 00       	call   80105de7 <holding>
801056e0:	83 c4 10             	add    $0x10,%esp
801056e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!lock) {
801056e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056ea:	75 10                	jne    801056fc <statelist_move_from_to+0x39>
    acquire(&ptable.lock);
801056ec:	83 ec 0c             	sub    $0xc,%esp
801056ef:	68 80 39 11 80       	push   $0x80113980
801056f4:	e8 bb 05 00 00       	call   80105cb4 <acquire>
801056f9:	83 c4 10             	add    $0x10,%esp
  }
//cprintf("moving %s from %s to %s...", p->name, states[state_from], states[state_to]);
  assertState(p, state_from);
801056fc:	83 ec 08             	sub    $0x8,%esp
801056ff:	ff 75 08             	pushl  0x8(%ebp)
80105702:	ff 75 10             	pushl  0x10(%ebp)
80105705:	e8 1c 02 00 00       	call   80105926 <assertState>
8010570a:	83 c4 10             	add    $0x10,%esp

  struct proc **head, **tail;
  get_head_tail(&head, &tail, state_from);
8010570d:	83 ec 04             	sub    $0x4,%esp
80105710:	ff 75 08             	pushl  0x8(%ebp)
80105713:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105716:	50                   	push   %eax
80105717:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010571a:	50                   	push   %eax
8010571b:	e8 7a 00 00 00       	call   8010579a <get_head_tail>
80105720:	83 c4 10             	add    $0x10,%esp

  if (stateListRemove(head,tail,p)) {
80105723:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105729:	83 ec 04             	sub    $0x4,%esp
8010572c:	ff 75 10             	pushl  0x10(%ebp)
8010572f:	52                   	push   %edx
80105730:	50                   	push   %eax
80105731:	e8 da fd ff ff       	call   80105510 <stateListRemove>
80105736:	83 c4 10             	add    $0x10,%esp
80105739:	85 c0                	test   %eax,%eax
8010573b:	74 0d                	je     8010574a <statelist_move_from_to+0x87>
    panic("in proc.c: in statelist_move_from_to(): proc not found in list for removal\n");
8010573d:	83 ec 0c             	sub    $0xc,%esp
80105740:	68 10 98 10 80       	push   $0x80109810
80105745:	e8 1c ae ff ff       	call   80100566 <panic>
  }

  get_head_tail(&head, &tail, state_to);
8010574a:	83 ec 04             	sub    $0x4,%esp
8010574d:	ff 75 0c             	pushl  0xc(%ebp)
80105750:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105753:	50                   	push   %eax
80105754:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105757:	50                   	push   %eax
80105758:	e8 3d 00 00 00       	call   8010579a <get_head_tail>
8010575d:	83 c4 10             	add    $0x10,%esp

  stateListAdd(head, tail, p);
80105760:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105766:	83 ec 04             	sub    $0x4,%esp
80105769:	ff 75 10             	pushl  0x10(%ebp)
8010576c:	52                   	push   %edx
8010576d:	50                   	push   %eax
8010576e:	e8 3e fd ff ff       	call   801054b1 <stateListAdd>
80105773:	83 c4 10             	add    $0x10,%esp
  p->state = state_to;
80105776:	8b 45 10             	mov    0x10(%ebp),%eax
80105779:	8b 55 0c             	mov    0xc(%ebp),%edx
8010577c:	89 50 0c             	mov    %edx,0xc(%eax)

  if (!lock) release(&ptable.lock);
8010577f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105783:	75 13                	jne    80105798 <statelist_move_from_to+0xd5>
80105785:	83 ec 0c             	sub    $0xc,%esp
80105788:	68 80 39 11 80       	push   $0x80113980
8010578d:	e8 89 05 00 00       	call   80105d1b <release>
80105792:	83 c4 10             	add    $0x10,%esp
80105795:	eb 01                	jmp    80105798 <statelist_move_from_to+0xd5>
}

// Student added helpers:
static void
statelist_move_from_to(enum procstate state_from, enum procstate state_to, struct proc* p) {
  if (!p) return;
80105797:	90                   	nop
  stateListAdd(head, tail, p);
  p->state = state_to;

  if (!lock) release(&ptable.lock);
//cprintf(" done.\n");
}
80105798:	c9                   	leave  
80105799:	c3                   	ret    

8010579a <get_head_tail>:

static void
get_head_tail(struct proc*** head, struct proc*** tail, enum procstate state_from) {
8010579a:	55                   	push   %ebp
8010579b:	89 e5                	mov    %esp,%ebp
8010579d:	83 ec 08             	sub    $0x8,%esp
  switch (state_from) {
801057a0:	83 7d 10 05          	cmpl   $0x5,0x10(%ebp)
801057a4:	0f 87 87 00 00 00    	ja     80105831 <get_head_tail+0x97>
801057aa:	8b 45 10             	mov    0x10(%ebp),%eax
801057ad:	c1 e0 02             	shl    $0x2,%eax
801057b0:	05 90 98 10 80       	add    $0x80109890,%eax
801057b5:	8b 00                	mov    (%eax),%eax
801057b7:	ff e0                	jmp    *%eax
    case UNUSED:
      *head = &ptable.pLists.free;
801057b9:	8b 45 08             	mov    0x8(%ebp),%eax
801057bc:	c7 00 bc 5e 11 80    	movl   $0x80115ebc,(%eax)
      *tail = &ptable.pLists.freeTail;
801057c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801057c5:	c7 00 c0 5e 11 80    	movl   $0x80115ec0,(%eax)
      break;
801057cb:	eb 71                	jmp    8010583e <get_head_tail+0xa4>
    case EMBRYO:
      *head = &ptable.pLists.embryo;
801057cd:	8b 45 08             	mov    0x8(%ebp),%eax
801057d0:	c7 00 dc 5e 11 80    	movl   $0x80115edc,(%eax)
      *tail = &ptable.pLists.embryoTail;
801057d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801057d9:	c7 00 e0 5e 11 80    	movl   $0x80115ee0,(%eax)
      break;
801057df:	eb 5d                	jmp    8010583e <get_head_tail+0xa4>
    case SLEEPING:
      *head = &ptable.pLists.sleep;
801057e1:	8b 45 08             	mov    0x8(%ebp),%eax
801057e4:	c7 00 c4 5e 11 80    	movl   $0x80115ec4,(%eax)
      *tail = &ptable.pLists.sleepTail;
801057ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ed:	c7 00 c8 5e 11 80    	movl   $0x80115ec8,(%eax)
      break;
801057f3:	eb 49                	jmp    8010583e <get_head_tail+0xa4>
    case RUNNABLE:
      *head = &ptable.pLists.ready;
801057f5:	8b 45 08             	mov    0x8(%ebp),%eax
801057f8:	c7 00 b4 5e 11 80    	movl   $0x80115eb4,(%eax)
      *tail = &ptable.pLists.readyTail;
801057fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105801:	c7 00 b8 5e 11 80    	movl   $0x80115eb8,(%eax)
      break;
80105807:	eb 35                	jmp    8010583e <get_head_tail+0xa4>
    case RUNNING:
      *head = &ptable.pLists.running;
80105809:	8b 45 08             	mov    0x8(%ebp),%eax
8010580c:	c7 00 d4 5e 11 80    	movl   $0x80115ed4,(%eax)
      *tail = &ptable.pLists.runningTail;
80105812:	8b 45 0c             	mov    0xc(%ebp),%eax
80105815:	c7 00 d8 5e 11 80    	movl   $0x80115ed8,(%eax)
      break;
8010581b:	eb 21                	jmp    8010583e <get_head_tail+0xa4>
    case ZOMBIE:
      *head = &ptable.pLists.zombie;
8010581d:	8b 45 08             	mov    0x8(%ebp),%eax
80105820:	c7 00 cc 5e 11 80    	movl   $0x80115ecc,(%eax)
      *tail = &ptable.pLists.zombieTail;
80105826:	8b 45 0c             	mov    0xc(%ebp),%eax
80105829:	c7 00 d0 5e 11 80    	movl   $0x80115ed0,(%eax)
      break;
8010582f:	eb 0d                	jmp    8010583e <get_head_tail+0xa4>
    default:
      panic("in get_head_tail(): argument is not a valid state\n");
80105831:	83 ec 0c             	sub    $0xc,%esp
80105834:	68 5c 98 10 80       	push   $0x8010985c
80105839:	e8 28 ad ff ff       	call   80100566 <panic>
  }
}
8010583e:	90                   	nop
8010583f:	c9                   	leave  
80105840:	c3                   	ret    

80105841 <statelist_search>:

static struct proc*
statelist_search(int pid) {
80105841:	55                   	push   %ebp
80105842:	89 e5                	mov    %esp,%ebp
80105844:	83 ec 18             	sub    $0x18,%esp
  struct proc * p;
  for (int i = 0; i <= ZOMBIE; ++i) {
80105847:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010584e:	eb 24                	jmp    80105874 <statelist_search+0x33>
    p = list_search(pid, i);
80105850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105853:	83 ec 08             	sub    $0x8,%esp
80105856:	50                   	push   %eax
80105857:	ff 75 08             	pushl  0x8(%ebp)
8010585a:	e8 22 00 00 00       	call   80105881 <list_search>
8010585f:	83 c4 10             	add    $0x10,%esp
80105862:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (p) return p;
80105865:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105869:	74 05                	je     80105870 <statelist_search+0x2f>
8010586b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586e:	eb 0f                	jmp    8010587f <statelist_search+0x3e>
}

static struct proc*
statelist_search(int pid) {
  struct proc * p;
  for (int i = 0; i <= ZOMBIE; ++i) {
80105870:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105874:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
80105878:	7e d6                	jle    80105850 <statelist_search+0xf>
    p = list_search(pid, i);
    if (p) return p;
  }
  return 0;
8010587a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010587f:	c9                   	leave  
80105880:	c3                   	ret    

80105881 <list_search>:

static struct proc*
list_search(int pid, enum procstate state) {
80105881:	55                   	push   %ebp
80105882:	89 e5                	mov    %esp,%ebp
80105884:	83 ec 18             	sub    $0x18,%esp
  struct proc **head, **tail, *p;

  get_head_tail(&head, &tail, state);
80105887:	83 ec 04             	sub    $0x4,%esp
8010588a:	ff 75 0c             	pushl  0xc(%ebp)
8010588d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105890:	50                   	push   %eax
80105891:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105894:	50                   	push   %eax
80105895:	e8 00 ff ff ff       	call   8010579a <get_head_tail>
8010589a:	83 c4 10             	add    $0x10,%esp
  p = *head;
8010589d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a0:	8b 00                	mov    (%eax),%eax
801058a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while (p) {
801058a5:	eb 1e                	jmp    801058c5 <list_search+0x44>
    if (p->pid == pid) return p;
801058a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058aa:	8b 50 10             	mov    0x10(%eax),%edx
801058ad:	8b 45 08             	mov    0x8(%ebp),%eax
801058b0:	39 c2                	cmp    %eax,%edx
801058b2:	75 05                	jne    801058b9 <list_search+0x38>
801058b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058b7:	eb 17                	jmp    801058d0 <list_search+0x4f>
    p = p->next;
801058b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058bc:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
801058c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
list_search(int pid, enum procstate state) {
  struct proc **head, **tail, *p;

  get_head_tail(&head, &tail, state);
  p = *head;
  while (p) {
801058c5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058c9:	75 dc                	jne    801058a7 <list_search+0x26>
    if (p->pid == pid) return p;
    p = p->next;
  }

  return 0;
801058cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058d0:	c9                   	leave  
801058d1:	c3                   	ret    

801058d2 <get_head>:

static struct proc*
get_head(enum procstate state) {
801058d2:	55                   	push   %ebp
801058d3:	89 e5                	mov    %esp,%ebp
801058d5:	83 ec 08             	sub    $0x8,%esp
  switch (state) {
801058d8:	83 7d 08 05          	cmpl   $0x5,0x8(%ebp)
801058dc:	77 39                	ja     80105917 <get_head+0x45>
801058de:	8b 45 08             	mov    0x8(%ebp),%eax
801058e1:	c1 e0 02             	shl    $0x2,%eax
801058e4:	05 a8 98 10 80       	add    $0x801098a8,%eax
801058e9:	8b 00                	mov    (%eax),%eax
801058eb:	ff e0                	jmp    *%eax
    case UNUSED:
      return ptable.pLists.free;
801058ed:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
801058f2:	eb 30                	jmp    80105924 <get_head+0x52>
    case EMBRYO:
      return ptable.pLists.embryo;
801058f4:	a1 dc 5e 11 80       	mov    0x80115edc,%eax
801058f9:	eb 29                	jmp    80105924 <get_head+0x52>
    case SLEEPING:
      return ptable.pLists.sleep;
801058fb:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80105900:	eb 22                	jmp    80105924 <get_head+0x52>
    case RUNNABLE:
      return ptable.pLists.ready;
80105902:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80105907:	eb 1b                	jmp    80105924 <get_head+0x52>
    case RUNNING:
      return ptable.pLists.running;
80105909:	a1 d4 5e 11 80       	mov    0x80115ed4,%eax
8010590e:	eb 14                	jmp    80105924 <get_head+0x52>
    case ZOMBIE:
      return ptable.pLists.zombie;
80105910:	a1 cc 5e 11 80       	mov    0x80115ecc,%eax
80105915:	eb 0d                	jmp    80105924 <get_head+0x52>
    default:
      panic("in get_head_tail(): argument is not a valid state\n");
80105917:	83 ec 0c             	sub    $0xc,%esp
8010591a:	68 5c 98 10 80       	push   $0x8010985c
8010591f:	e8 42 ac ff ff       	call   80100566 <panic>
  }
}
80105924:	c9                   	leave  
80105925:	c3                   	ret    

80105926 <assertState>:
  

static void
assertState(struct proc* p, enum procstate state) {
80105926:	55                   	push   %ebp
80105927:	89 e5                	mov    %esp,%ebp
80105929:	83 ec 08             	sub    $0x8,%esp
  if (!p) 
8010592c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105930:	75 0d                	jne    8010593f <assertState+0x19>
    panic("in proc.c: in assertState(): proc* is NULL\n");
80105932:	83 ec 0c             	sub    $0xc,%esp
80105935:	68 c0 98 10 80       	push   $0x801098c0
8010593a:	e8 27 ac ff ff       	call   80100566 <panic>
  if (p->state != state) {
8010593f:	8b 45 08             	mov    0x8(%ebp),%eax
80105942:	8b 40 0c             	mov    0xc(%eax),%eax
80105945:	3b 45 0c             	cmp    0xc(%ebp),%eax
80105948:	74 36                	je     80105980 <assertState+0x5a>
    cprintf("proc state: %s, asserted state: %s\n", states[p->state], states[state]);
8010594a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010594d:	8b 14 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%edx
80105954:	8b 45 08             	mov    0x8(%ebp),%eax
80105957:	8b 40 0c             	mov    0xc(%eax),%eax
8010595a:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105961:	83 ec 04             	sub    $0x4,%esp
80105964:	52                   	push   %edx
80105965:	50                   	push   %eax
80105966:	68 ec 98 10 80       	push   $0x801098ec
8010596b:	e8 56 aa ff ff       	call   801003c6 <cprintf>
80105970:	83 c4 10             	add    $0x10,%esp
    panic("in proc.c: in assertState(): proc state does not match asserted state\n");
80105973:	83 ec 0c             	sub    $0xc,%esp
80105976:	68 10 99 10 80       	push   $0x80109910
8010597b:	e8 e6 ab ff ff       	call   80100566 <panic>
  }
}
80105980:	90                   	nop
80105981:	c9                   	leave  
80105982:	c3                   	ret    

80105983 <statelist_abandon_children>:

static void
statelist_abandon_children(struct proc* p) {
80105983:	55                   	push   %ebp
80105984:	89 e5                	mov    %esp,%ebp
80105986:	83 ec 18             	sub    $0x18,%esp
  for (int i = 0; i <= ZOMBIE; ++i)
80105989:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105990:	eb 16                	jmp    801059a8 <statelist_abandon_children+0x25>
    list_abandon_children(p, i);
80105992:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105995:	83 ec 08             	sub    $0x8,%esp
80105998:	50                   	push   %eax
80105999:	ff 75 08             	pushl  0x8(%ebp)
8010599c:	e8 10 00 00 00       	call   801059b1 <list_abandon_children>
801059a1:	83 c4 10             	add    $0x10,%esp
  }
}

static void
statelist_abandon_children(struct proc* p) {
  for (int i = 0; i <= ZOMBIE; ++i)
801059a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801059a8:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
801059ac:	7e e4                	jle    80105992 <statelist_abandon_children+0xf>
    list_abandon_children(p, i);
}
801059ae:	90                   	nop
801059af:	c9                   	leave  
801059b0:	c3                   	ret    

801059b1 <list_abandon_children>:

static void
list_abandon_children(struct proc* parent, enum procstate state) {
801059b1:	55                   	push   %ebp
801059b2:	89 e5                	mov    %esp,%ebp
801059b4:	83 ec 18             	sub    $0x18,%esp
  //struct proc **head, **tail;
  struct proc *p;

  //get_head_tail(&head, &tail, state);
  //p = *head;
  p = get_head(state);
801059b7:	83 ec 0c             	sub    $0xc,%esp
801059ba:	ff 75 0c             	pushl  0xc(%ebp)
801059bd:	e8 10 ff ff ff       	call   801058d2 <get_head>
801059c2:	83 c4 10             	add    $0x10,%esp
801059c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while (p) {
801059c8:	eb 3f                	jmp    80105a09 <list_abandon_children+0x58>
    if (p->parent == parent) {
801059ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cd:	8b 40 14             	mov    0x14(%eax),%eax
801059d0:	3b 45 08             	cmp    0x8(%ebp),%eax
801059d3:	75 28                	jne    801059fd <list_abandon_children+0x4c>
      p->parent = initproc;
801059d5:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	89 50 14             	mov    %edx,0x14(%eax)
      if (p->state == ZOMBIE)
801059e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e4:	8b 40 0c             	mov    0xc(%eax),%eax
801059e7:	83 f8 05             	cmp    $0x5,%eax
801059ea:	75 11                	jne    801059fd <list_abandon_children+0x4c>
        wakeup1(initproc);
801059ec:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801059f1:	83 ec 0c             	sub    $0xc,%esp
801059f4:	50                   	push   %eax
801059f5:	e8 bd f5 ff ff       	call   80104fb7 <wakeup1>
801059fa:	83 c4 10             	add    $0x10,%esp
    }
    p = p->next;
801059fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a00:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc *p;

  //get_head_tail(&head, &tail, state);
  //p = *head;
  p = get_head(state);
  while (p) {
80105a09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a0d:	75 bb                	jne    801059ca <list_abandon_children+0x19>
      if (p->state == ZOMBIE)
        wakeup1(initproc);
    }
    p = p->next;
  }
}
80105a0f:	90                   	nop
80105a10:	c9                   	leave  
80105a11:	c3                   	ret    

80105a12 <list_display>:

static void
list_display(struct proc* p) {
80105a12:	55                   	push   %ebp
80105a13:	89 e5                	mov    %esp,%ebp
80105a15:	83 ec 18             	sub    $0x18,%esp
  if (!p) {
80105a18:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105a1c:	75 15                	jne    80105a33 <list_display+0x21>
    cprintf("Nothing to display\n");
80105a1e:	83 ec 0c             	sub    $0xc,%esp
80105a21:	68 57 99 10 80       	push   $0x80109957
80105a26:	e8 9b a9 ff ff       	call   801003c6 <cprintf>
80105a2b:	83 c4 10             	add    $0x10,%esp
    return;
80105a2e:	e9 9d 00 00 00       	jmp    80105ad0 <list_display+0xbe>
  }
  int lock = holding(&ptable.lock);
80105a33:	83 ec 0c             	sub    $0xc,%esp
80105a36:	68 80 39 11 80       	push   $0x80113980
80105a3b:	e8 a7 03 00 00       	call   80105de7 <holding>
80105a40:	83 c4 10             	add    $0x10,%esp
80105a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!lock) acquire(&ptable.lock);
80105a46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a4a:	75 10                	jne    80105a5c <list_display+0x4a>
80105a4c:	83 ec 0c             	sub    $0xc,%esp
80105a4f:	68 80 39 11 80       	push   $0x80113980
80105a54:	e8 5b 02 00 00       	call   80105cb4 <acquire>
80105a59:	83 c4 10             	add    $0x10,%esp

  cprintf("%d", p->pid);
80105a5c:	8b 45 08             	mov    0x8(%ebp),%eax
80105a5f:	8b 40 10             	mov    0x10(%eax),%eax
80105a62:	83 ec 08             	sub    $0x8,%esp
80105a65:	50                   	push   %eax
80105a66:	68 6b 99 10 80       	push   $0x8010996b
80105a6b:	e8 56 a9 ff ff       	call   801003c6 <cprintf>
80105a70:	83 c4 10             	add    $0x10,%esp
  p = p->next;
80105a73:	8b 45 08             	mov    0x8(%ebp),%eax
80105a76:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105a7c:	89 45 08             	mov    %eax,0x8(%ebp)
  while (p) {
80105a7f:	eb 23                	jmp    80105aa4 <list_display+0x92>
  cprintf("->%d", p->pid);
80105a81:	8b 45 08             	mov    0x8(%ebp),%eax
80105a84:	8b 40 10             	mov    0x10(%eax),%eax
80105a87:	83 ec 08             	sub    $0x8,%esp
80105a8a:	50                   	push   %eax
80105a8b:	68 6e 99 10 80       	push   $0x8010996e
80105a90:	e8 31 a9 ff ff       	call   801003c6 <cprintf>
80105a95:	83 c4 10             	add    $0x10,%esp
  p = p->next;
80105a98:	8b 45 08             	mov    0x8(%ebp),%eax
80105a9b:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105aa1:	89 45 08             	mov    %eax,0x8(%ebp)
  int lock = holding(&ptable.lock);
  if (!lock) acquire(&ptable.lock);

  cprintf("%d", p->pid);
  p = p->next;
  while (p) {
80105aa4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105aa8:	75 d7                	jne    80105a81 <list_display+0x6f>
  cprintf("->%d", p->pid);
  p = p->next;
  }
  cprintf("\n");
80105aaa:	83 ec 0c             	sub    $0xc,%esp
80105aad:	68 d3 97 10 80       	push   $0x801097d3
80105ab2:	e8 0f a9 ff ff       	call   801003c6 <cprintf>
80105ab7:	83 c4 10             	add    $0x10,%esp

  if (!lock) release(&ptable.lock);
80105aba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105abe:	75 10                	jne    80105ad0 <list_display+0xbe>
80105ac0:	83 ec 0c             	sub    $0xc,%esp
80105ac3:	68 80 39 11 80       	push   $0x80113980
80105ac8:	e8 4e 02 00 00       	call   80105d1b <release>
80105acd:	83 c4 10             	add    $0x10,%esp
}
80105ad0:	c9                   	leave  
80105ad1:	c3                   	ret    

80105ad2 <display_readylist>:
  
void
display_readylist() {
80105ad2:	55                   	push   %ebp
80105ad3:	89 e5                	mov    %esp,%ebp
80105ad5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80105ad8:	83 ec 0c             	sub    $0xc,%esp
80105adb:	68 80 39 11 80       	push   $0x80113980
80105ae0:	e8 cf 01 00 00       	call   80105cb4 <acquire>
80105ae5:	83 c4 10             	add    $0x10,%esp
  cprintf("\nReady List Processes:\n");
80105ae8:	83 ec 0c             	sub    $0xc,%esp
80105aeb:	68 73 99 10 80       	push   $0x80109973
80105af0:	e8 d1 a8 ff ff       	call   801003c6 <cprintf>
80105af5:	83 c4 10             	add    $0x10,%esp
  list_display(ptable.pLists.ready);
80105af8:	a1 b4 5e 11 80       	mov    0x80115eb4,%eax
80105afd:	83 ec 0c             	sub    $0xc,%esp
80105b00:	50                   	push   %eax
80105b01:	e8 0c ff ff ff       	call   80105a12 <list_display>
80105b06:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105b09:	83 ec 0c             	sub    $0xc,%esp
80105b0c:	68 80 39 11 80       	push   $0x80113980
80105b11:	e8 05 02 00 00       	call   80105d1b <release>
80105b16:	83 c4 10             	add    $0x10,%esp
}
80105b19:	90                   	nop
80105b1a:	c9                   	leave  
80105b1b:	c3                   	ret    

80105b1c <display_freelist>:

void
display_freelist() {
80105b1c:	55                   	push   %ebp
80105b1d:	89 e5                	mov    %esp,%ebp
80105b1f:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc* p = ptable.pLists.free;
80105b22:	a1 bc 5e 11 80       	mov    0x80115ebc,%eax
80105b27:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(i = 0; p;++i)
80105b2a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105b31:	eb 10                	jmp    80105b43 <display_freelist+0x27>
    p = p->next;
80105b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b36:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105b3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
void
display_freelist() {
  int i;
  struct proc* p = ptable.pLists.free;

  for(i = 0; p;++i)
80105b3f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105b43:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b47:	75 ea                	jne    80105b33 <display_freelist+0x17>
    p = p->next;

  cprintf("\nFree List Size: %d processes\n", i);
80105b49:	83 ec 08             	sub    $0x8,%esp
80105b4c:	ff 75 f4             	pushl  -0xc(%ebp)
80105b4f:	68 8c 99 10 80       	push   $0x8010998c
80105b54:	e8 6d a8 ff ff       	call   801003c6 <cprintf>
80105b59:	83 c4 10             	add    $0x10,%esp
}
80105b5c:	90                   	nop
80105b5d:	c9                   	leave  
80105b5e:	c3                   	ret    

80105b5f <display_sleeplist>:

void
display_sleeplist() {
80105b5f:	55                   	push   %ebp
80105b60:	89 e5                	mov    %esp,%ebp
80105b62:	83 ec 08             	sub    $0x8,%esp
  cprintf("\nSleep List Processes:\n");
80105b65:	83 ec 0c             	sub    $0xc,%esp
80105b68:	68 ab 99 10 80       	push   $0x801099ab
80105b6d:	e8 54 a8 ff ff       	call   801003c6 <cprintf>
80105b72:	83 c4 10             	add    $0x10,%esp
  list_display(ptable.pLists.sleep);
80105b75:	a1 c4 5e 11 80       	mov    0x80115ec4,%eax
80105b7a:	83 ec 0c             	sub    $0xc,%esp
80105b7d:	50                   	push   %eax
80105b7e:	e8 8f fe ff ff       	call   80105a12 <list_display>
80105b83:	83 c4 10             	add    $0x10,%esp
}
80105b86:	90                   	nop
80105b87:	c9                   	leave  
80105b88:	c3                   	ret    

80105b89 <display_zombielist>:

void
display_zombielist() {
80105b89:	55                   	push   %ebp
80105b8a:	89 e5                	mov    %esp,%ebp
80105b8c:	83 ec 18             	sub    $0x18,%esp
  struct proc* p = ptable.pLists.zombie;
80105b8f:	a1 cc 5e 11 80       	mov    0x80115ecc,%eax
80105b94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cprintf("\nZombie List Processes:\n");
80105b97:	83 ec 0c             	sub    $0xc,%esp
80105b9a:	68 c3 99 10 80       	push   $0x801099c3
80105b9f:	e8 22 a8 ff ff       	call   801003c6 <cprintf>
80105ba4:	83 c4 10             	add    $0x10,%esp

  if (!p) {
80105ba7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bab:	75 15                	jne    80105bc2 <display_zombielist+0x39>
    cprintf("Nothing to display\n");
80105bad:	83 ec 0c             	sub    $0xc,%esp
80105bb0:	68 57 99 10 80       	push   $0x80109957
80105bb5:	e8 0c a8 ff ff       	call   801003c6 <cprintf>
80105bba:	83 c4 10             	add    $0x10,%esp
    return;
80105bbd:	e9 96 00 00 00       	jmp    80105c58 <display_zombielist+0xcf>
  }

  cprintf("(%d,%d)", p->pid, (p->parent)? p->parent->pid : p->pid);
80105bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc5:	8b 40 14             	mov    0x14(%eax),%eax
80105bc8:	85 c0                	test   %eax,%eax
80105bca:	74 0b                	je     80105bd7 <display_zombielist+0x4e>
80105bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcf:	8b 40 14             	mov    0x14(%eax),%eax
80105bd2:	8b 40 10             	mov    0x10(%eax),%eax
80105bd5:	eb 06                	jmp    80105bdd <display_zombielist+0x54>
80105bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bda:	8b 40 10             	mov    0x10(%eax),%eax
80105bdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105be0:	8b 52 10             	mov    0x10(%edx),%edx
80105be3:	83 ec 04             	sub    $0x4,%esp
80105be6:	50                   	push   %eax
80105be7:	52                   	push   %edx
80105be8:	68 dc 99 10 80       	push   $0x801099dc
80105bed:	e8 d4 a7 ff ff       	call   801003c6 <cprintf>
80105bf2:	83 c4 10             	add    $0x10,%esp
  p = p->next;
80105bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf8:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105bfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while (p) {
80105c01:	eb 3f                	jmp    80105c42 <display_zombielist+0xb9>
    cprintf("->(%d,%d)", p->pid, (p->parent)? p->parent->pid : p->pid);
80105c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c06:	8b 40 14             	mov    0x14(%eax),%eax
80105c09:	85 c0                	test   %eax,%eax
80105c0b:	74 0b                	je     80105c18 <display_zombielist+0x8f>
80105c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c10:	8b 40 14             	mov    0x14(%eax),%eax
80105c13:	8b 40 10             	mov    0x10(%eax),%eax
80105c16:	eb 06                	jmp    80105c1e <display_zombielist+0x95>
80105c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c1b:	8b 40 10             	mov    0x10(%eax),%eax
80105c1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c21:	8b 52 10             	mov    0x10(%edx),%edx
80105c24:	83 ec 04             	sub    $0x4,%esp
80105c27:	50                   	push   %eax
80105c28:	52                   	push   %edx
80105c29:	68 e4 99 10 80       	push   $0x801099e4
80105c2e:	e8 93 a7 ff ff       	call   801003c6 <cprintf>
80105c33:	83 c4 10             	add    $0x10,%esp
    p = p->next;
80105c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c39:	8b 80 90 00 00 00    	mov    0x90(%eax),%eax
80105c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return;
  }

  cprintf("(%d,%d)", p->pid, (p->parent)? p->parent->pid : p->pid);
  p = p->next;
  while (p) {
80105c42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c46:	75 bb                	jne    80105c03 <display_zombielist+0x7a>
    cprintf("->(%d,%d)", p->pid, (p->parent)? p->parent->pid : p->pid);
    p = p->next;
  }
  cprintf("\n");
80105c48:	83 ec 0c             	sub    $0xc,%esp
80105c4b:	68 d3 97 10 80       	push   $0x801097d3
80105c50:	e8 71 a7 ff ff       	call   801003c6 <cprintf>
80105c55:	83 c4 10             	add    $0x10,%esp
}
80105c58:	c9                   	leave  
80105c59:	c3                   	ret    

80105c5a <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105c5a:	55                   	push   %ebp
80105c5b:	89 e5                	mov    %esp,%ebp
80105c5d:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105c60:	9c                   	pushf  
80105c61:	58                   	pop    %eax
80105c62:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105c65:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c68:	c9                   	leave  
80105c69:	c3                   	ret    

80105c6a <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105c6a:	55                   	push   %ebp
80105c6b:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105c6d:	fa                   	cli    
}
80105c6e:	90                   	nop
80105c6f:	5d                   	pop    %ebp
80105c70:	c3                   	ret    

80105c71 <sti>:

static inline void
sti(void)
{
80105c71:	55                   	push   %ebp
80105c72:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105c74:	fb                   	sti    
}
80105c75:	90                   	nop
80105c76:	5d                   	pop    %ebp
80105c77:	c3                   	ret    

80105c78 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105c78:	55                   	push   %ebp
80105c79:	89 e5                	mov    %esp,%ebp
80105c7b:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105c7e:	8b 55 08             	mov    0x8(%ebp),%edx
80105c81:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105c87:	f0 87 02             	lock xchg %eax,(%edx)
80105c8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105c8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c90:	c9                   	leave  
80105c91:	c3                   	ret    

80105c92 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105c92:	55                   	push   %ebp
80105c93:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105c95:	8b 45 08             	mov    0x8(%ebp),%eax
80105c98:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c9b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105c9e:	8b 45 08             	mov    0x8(%ebp),%eax
80105ca1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80105caa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105cb1:	90                   	nop
80105cb2:	5d                   	pop    %ebp
80105cb3:	c3                   	ret    

80105cb4 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105cb4:	55                   	push   %ebp
80105cb5:	89 e5                	mov    %esp,%ebp
80105cb7:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105cba:	e8 52 01 00 00       	call   80105e11 <pushcli>
  if(holding(lk))
80105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc2:	83 ec 0c             	sub    $0xc,%esp
80105cc5:	50                   	push   %eax
80105cc6:	e8 1c 01 00 00       	call   80105de7 <holding>
80105ccb:	83 c4 10             	add    $0x10,%esp
80105cce:	85 c0                	test   %eax,%eax
80105cd0:	74 0d                	je     80105cdf <acquire+0x2b>
    panic("acquire");
80105cd2:	83 ec 0c             	sub    $0xc,%esp
80105cd5:	68 ee 99 10 80       	push   $0x801099ee
80105cda:	e8 87 a8 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105cdf:	90                   	nop
80105ce0:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce3:	83 ec 08             	sub    $0x8,%esp
80105ce6:	6a 01                	push   $0x1
80105ce8:	50                   	push   %eax
80105ce9:	e8 8a ff ff ff       	call   80105c78 <xchg>
80105cee:	83 c4 10             	add    $0x10,%esp
80105cf1:	85 c0                	test   %eax,%eax
80105cf3:	75 eb                	jne    80105ce0 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105cff:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105d02:	8b 45 08             	mov    0x8(%ebp),%eax
80105d05:	83 c0 0c             	add    $0xc,%eax
80105d08:	83 ec 08             	sub    $0x8,%esp
80105d0b:	50                   	push   %eax
80105d0c:	8d 45 08             	lea    0x8(%ebp),%eax
80105d0f:	50                   	push   %eax
80105d10:	e8 58 00 00 00       	call   80105d6d <getcallerpcs>
80105d15:	83 c4 10             	add    $0x10,%esp
}
80105d18:	90                   	nop
80105d19:	c9                   	leave  
80105d1a:	c3                   	ret    

80105d1b <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105d1b:	55                   	push   %ebp
80105d1c:	89 e5                	mov    %esp,%ebp
80105d1e:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105d21:	83 ec 0c             	sub    $0xc,%esp
80105d24:	ff 75 08             	pushl  0x8(%ebp)
80105d27:	e8 bb 00 00 00       	call   80105de7 <holding>
80105d2c:	83 c4 10             	add    $0x10,%esp
80105d2f:	85 c0                	test   %eax,%eax
80105d31:	75 0d                	jne    80105d40 <release+0x25>
    panic("release");
80105d33:	83 ec 0c             	sub    $0xc,%esp
80105d36:	68 f6 99 10 80       	push   $0x801099f6
80105d3b:	e8 26 a8 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105d40:	8b 45 08             	mov    0x8(%ebp),%eax
80105d43:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d4d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105d54:	8b 45 08             	mov    0x8(%ebp),%eax
80105d57:	83 ec 08             	sub    $0x8,%esp
80105d5a:	6a 00                	push   $0x0
80105d5c:	50                   	push   %eax
80105d5d:	e8 16 ff ff ff       	call   80105c78 <xchg>
80105d62:	83 c4 10             	add    $0x10,%esp

  popcli();
80105d65:	e8 ec 00 00 00       	call   80105e56 <popcli>
}
80105d6a:	90                   	nop
80105d6b:	c9                   	leave  
80105d6c:	c3                   	ret    

80105d6d <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105d6d:	55                   	push   %ebp
80105d6e:	89 e5                	mov    %esp,%ebp
80105d70:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105d73:	8b 45 08             	mov    0x8(%ebp),%eax
80105d76:	83 e8 08             	sub    $0x8,%eax
80105d79:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105d7c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105d83:	eb 38                	jmp    80105dbd <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105d85:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105d89:	74 53                	je     80105dde <getcallerpcs+0x71>
80105d8b:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105d92:	76 4a                	jbe    80105dde <getcallerpcs+0x71>
80105d94:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105d98:	74 44                	je     80105dde <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105d9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105d9d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105da4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105da7:	01 c2                	add    %eax,%edx
80105da9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dac:	8b 40 04             	mov    0x4(%eax),%eax
80105daf:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105db1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105db4:	8b 00                	mov    (%eax),%eax
80105db6:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105db9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105dbd:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105dc1:	7e c2                	jle    80105d85 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105dc3:	eb 19                	jmp    80105dde <getcallerpcs+0x71>
    pcs[i] = 0;
80105dc5:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105dc8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dd2:	01 d0                	add    %edx,%eax
80105dd4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105dda:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105dde:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105de2:	7e e1                	jle    80105dc5 <getcallerpcs+0x58>
    pcs[i] = 0;
}
80105de4:	90                   	nop
80105de5:	c9                   	leave  
80105de6:	c3                   	ret    

80105de7 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105de7:	55                   	push   %ebp
80105de8:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105dea:	8b 45 08             	mov    0x8(%ebp),%eax
80105ded:	8b 00                	mov    (%eax),%eax
80105def:	85 c0                	test   %eax,%eax
80105df1:	74 17                	je     80105e0a <holding+0x23>
80105df3:	8b 45 08             	mov    0x8(%ebp),%eax
80105df6:	8b 50 08             	mov    0x8(%eax),%edx
80105df9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105dff:	39 c2                	cmp    %eax,%edx
80105e01:	75 07                	jne    80105e0a <holding+0x23>
80105e03:	b8 01 00 00 00       	mov    $0x1,%eax
80105e08:	eb 05                	jmp    80105e0f <holding+0x28>
80105e0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e0f:	5d                   	pop    %ebp
80105e10:	c3                   	ret    

80105e11 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105e11:	55                   	push   %ebp
80105e12:	89 e5                	mov    %esp,%ebp
80105e14:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105e17:	e8 3e fe ff ff       	call   80105c5a <readeflags>
80105e1c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105e1f:	e8 46 fe ff ff       	call   80105c6a <cli>
  if(cpu->ncli++ == 0)
80105e24:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105e2b:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105e31:	8d 48 01             	lea    0x1(%eax),%ecx
80105e34:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105e3a:	85 c0                	test   %eax,%eax
80105e3c:	75 15                	jne    80105e53 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105e3e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e44:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e47:	81 e2 00 02 00 00    	and    $0x200,%edx
80105e4d:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105e53:	90                   	nop
80105e54:	c9                   	leave  
80105e55:	c3                   	ret    

80105e56 <popcli>:

void
popcli(void)
{
80105e56:	55                   	push   %ebp
80105e57:	89 e5                	mov    %esp,%ebp
80105e59:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105e5c:	e8 f9 fd ff ff       	call   80105c5a <readeflags>
80105e61:	25 00 02 00 00       	and    $0x200,%eax
80105e66:	85 c0                	test   %eax,%eax
80105e68:	74 0d                	je     80105e77 <popcli+0x21>
    panic("popcli - interruptible");
80105e6a:	83 ec 0c             	sub    $0xc,%esp
80105e6d:	68 fe 99 10 80       	push   $0x801099fe
80105e72:	e8 ef a6 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105e77:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105e7d:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105e83:	83 ea 01             	sub    $0x1,%edx
80105e86:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105e8c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105e92:	85 c0                	test   %eax,%eax
80105e94:	79 0d                	jns    80105ea3 <popcli+0x4d>
    panic("popcli");
80105e96:	83 ec 0c             	sub    $0xc,%esp
80105e99:	68 15 9a 10 80       	push   $0x80109a15
80105e9e:	e8 c3 a6 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105ea3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105ea9:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105eaf:	85 c0                	test   %eax,%eax
80105eb1:	75 15                	jne    80105ec8 <popcli+0x72>
80105eb3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105eb9:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105ebf:	85 c0                	test   %eax,%eax
80105ec1:	74 05                	je     80105ec8 <popcli+0x72>
    sti();
80105ec3:	e8 a9 fd ff ff       	call   80105c71 <sti>
}
80105ec8:	90                   	nop
80105ec9:	c9                   	leave  
80105eca:	c3                   	ret    

80105ecb <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105ecb:	55                   	push   %ebp
80105ecc:	89 e5                	mov    %esp,%ebp
80105ece:	57                   	push   %edi
80105ecf:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105ed0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ed3:	8b 55 10             	mov    0x10(%ebp),%edx
80105ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ed9:	89 cb                	mov    %ecx,%ebx
80105edb:	89 df                	mov    %ebx,%edi
80105edd:	89 d1                	mov    %edx,%ecx
80105edf:	fc                   	cld    
80105ee0:	f3 aa                	rep stos %al,%es:(%edi)
80105ee2:	89 ca                	mov    %ecx,%edx
80105ee4:	89 fb                	mov    %edi,%ebx
80105ee6:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105ee9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105eec:	90                   	nop
80105eed:	5b                   	pop    %ebx
80105eee:	5f                   	pop    %edi
80105eef:	5d                   	pop    %ebp
80105ef0:	c3                   	ret    

80105ef1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105ef1:	55                   	push   %ebp
80105ef2:	89 e5                	mov    %esp,%ebp
80105ef4:	57                   	push   %edi
80105ef5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105ef9:	8b 55 10             	mov    0x10(%ebp),%edx
80105efc:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eff:	89 cb                	mov    %ecx,%ebx
80105f01:	89 df                	mov    %ebx,%edi
80105f03:	89 d1                	mov    %edx,%ecx
80105f05:	fc                   	cld    
80105f06:	f3 ab                	rep stos %eax,%es:(%edi)
80105f08:	89 ca                	mov    %ecx,%edx
80105f0a:	89 fb                	mov    %edi,%ebx
80105f0c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105f0f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105f12:	90                   	nop
80105f13:	5b                   	pop    %ebx
80105f14:	5f                   	pop    %edi
80105f15:	5d                   	pop    %ebp
80105f16:	c3                   	ret    

80105f17 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105f17:	55                   	push   %ebp
80105f18:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105f1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105f1d:	83 e0 03             	and    $0x3,%eax
80105f20:	85 c0                	test   %eax,%eax
80105f22:	75 43                	jne    80105f67 <memset+0x50>
80105f24:	8b 45 10             	mov    0x10(%ebp),%eax
80105f27:	83 e0 03             	and    $0x3,%eax
80105f2a:	85 c0                	test   %eax,%eax
80105f2c:	75 39                	jne    80105f67 <memset+0x50>
    c &= 0xFF;
80105f2e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105f35:	8b 45 10             	mov    0x10(%ebp),%eax
80105f38:	c1 e8 02             	shr    $0x2,%eax
80105f3b:	89 c1                	mov    %eax,%ecx
80105f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f40:	c1 e0 18             	shl    $0x18,%eax
80105f43:	89 c2                	mov    %eax,%edx
80105f45:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f48:	c1 e0 10             	shl    $0x10,%eax
80105f4b:	09 c2                	or     %eax,%edx
80105f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f50:	c1 e0 08             	shl    $0x8,%eax
80105f53:	09 d0                	or     %edx,%eax
80105f55:	0b 45 0c             	or     0xc(%ebp),%eax
80105f58:	51                   	push   %ecx
80105f59:	50                   	push   %eax
80105f5a:	ff 75 08             	pushl  0x8(%ebp)
80105f5d:	e8 8f ff ff ff       	call   80105ef1 <stosl>
80105f62:	83 c4 0c             	add    $0xc,%esp
80105f65:	eb 12                	jmp    80105f79 <memset+0x62>
  } else
    stosb(dst, c, n);
80105f67:	8b 45 10             	mov    0x10(%ebp),%eax
80105f6a:	50                   	push   %eax
80105f6b:	ff 75 0c             	pushl  0xc(%ebp)
80105f6e:	ff 75 08             	pushl  0x8(%ebp)
80105f71:	e8 55 ff ff ff       	call   80105ecb <stosb>
80105f76:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105f79:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105f7c:	c9                   	leave  
80105f7d:	c3                   	ret    

80105f7e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105f7e:	55                   	push   %ebp
80105f7f:	89 e5                	mov    %esp,%ebp
80105f81:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105f84:	8b 45 08             	mov    0x8(%ebp),%eax
80105f87:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f8d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105f90:	eb 30                	jmp    80105fc2 <memcmp+0x44>
    if(*s1 != *s2)
80105f92:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f95:	0f b6 10             	movzbl (%eax),%edx
80105f98:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f9b:	0f b6 00             	movzbl (%eax),%eax
80105f9e:	38 c2                	cmp    %al,%dl
80105fa0:	74 18                	je     80105fba <memcmp+0x3c>
      return *s1 - *s2;
80105fa2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105fa5:	0f b6 00             	movzbl (%eax),%eax
80105fa8:	0f b6 d0             	movzbl %al,%edx
80105fab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105fae:	0f b6 00             	movzbl (%eax),%eax
80105fb1:	0f b6 c0             	movzbl %al,%eax
80105fb4:	29 c2                	sub    %eax,%edx
80105fb6:	89 d0                	mov    %edx,%eax
80105fb8:	eb 1a                	jmp    80105fd4 <memcmp+0x56>
    s1++, s2++;
80105fba:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105fbe:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105fc2:	8b 45 10             	mov    0x10(%ebp),%eax
80105fc5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105fc8:	89 55 10             	mov    %edx,0x10(%ebp)
80105fcb:	85 c0                	test   %eax,%eax
80105fcd:	75 c3                	jne    80105f92 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105fcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fd4:	c9                   	leave  
80105fd5:	c3                   	ret    

80105fd6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105fd6:	55                   	push   %ebp
80105fd7:	89 e5                	mov    %esp,%ebp
80105fd9:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80105fdf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105fe8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105feb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105fee:	73 54                	jae    80106044 <memmove+0x6e>
80105ff0:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ff3:	8b 45 10             	mov    0x10(%ebp),%eax
80105ff6:	01 d0                	add    %edx,%eax
80105ff8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ffb:	76 47                	jbe    80106044 <memmove+0x6e>
    s += n;
80105ffd:	8b 45 10             	mov    0x10(%ebp),%eax
80106000:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106003:	8b 45 10             	mov    0x10(%ebp),%eax
80106006:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80106009:	eb 13                	jmp    8010601e <memmove+0x48>
      *--d = *--s;
8010600b:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
8010600f:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80106013:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106016:	0f b6 10             	movzbl (%eax),%edx
80106019:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010601c:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
8010601e:	8b 45 10             	mov    0x10(%ebp),%eax
80106021:	8d 50 ff             	lea    -0x1(%eax),%edx
80106024:	89 55 10             	mov    %edx,0x10(%ebp)
80106027:	85 c0                	test   %eax,%eax
80106029:	75 e0                	jne    8010600b <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010602b:	eb 24                	jmp    80106051 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
8010602d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80106030:	8d 50 01             	lea    0x1(%eax),%edx
80106033:	89 55 f8             	mov    %edx,-0x8(%ebp)
80106036:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106039:	8d 4a 01             	lea    0x1(%edx),%ecx
8010603c:	89 4d fc             	mov    %ecx,-0x4(%ebp)
8010603f:	0f b6 12             	movzbl (%edx),%edx
80106042:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80106044:	8b 45 10             	mov    0x10(%ebp),%eax
80106047:	8d 50 ff             	lea    -0x1(%eax),%edx
8010604a:	89 55 10             	mov    %edx,0x10(%ebp)
8010604d:	85 c0                	test   %eax,%eax
8010604f:	75 dc                	jne    8010602d <memmove+0x57>
      *d++ = *s++;

  return dst;
80106051:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106054:	c9                   	leave  
80106055:	c3                   	ret    

80106056 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80106056:	55                   	push   %ebp
80106057:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80106059:	ff 75 10             	pushl  0x10(%ebp)
8010605c:	ff 75 0c             	pushl  0xc(%ebp)
8010605f:	ff 75 08             	pushl  0x8(%ebp)
80106062:	e8 6f ff ff ff       	call   80105fd6 <memmove>
80106067:	83 c4 0c             	add    $0xc,%esp
}
8010606a:	c9                   	leave  
8010606b:	c3                   	ret    

8010606c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010606c:	55                   	push   %ebp
8010606d:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010606f:	eb 0c                	jmp    8010607d <strncmp+0x11>
    n--, p++, q++;
80106071:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106075:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106079:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010607d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106081:	74 1a                	je     8010609d <strncmp+0x31>
80106083:	8b 45 08             	mov    0x8(%ebp),%eax
80106086:	0f b6 00             	movzbl (%eax),%eax
80106089:	84 c0                	test   %al,%al
8010608b:	74 10                	je     8010609d <strncmp+0x31>
8010608d:	8b 45 08             	mov    0x8(%ebp),%eax
80106090:	0f b6 10             	movzbl (%eax),%edx
80106093:	8b 45 0c             	mov    0xc(%ebp),%eax
80106096:	0f b6 00             	movzbl (%eax),%eax
80106099:	38 c2                	cmp    %al,%dl
8010609b:	74 d4                	je     80106071 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
8010609d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801060a1:	75 07                	jne    801060aa <strncmp+0x3e>
    return 0;
801060a3:	b8 00 00 00 00       	mov    $0x0,%eax
801060a8:	eb 16                	jmp    801060c0 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
801060aa:	8b 45 08             	mov    0x8(%ebp),%eax
801060ad:	0f b6 00             	movzbl (%eax),%eax
801060b0:	0f b6 d0             	movzbl %al,%edx
801060b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801060b6:	0f b6 00             	movzbl (%eax),%eax
801060b9:	0f b6 c0             	movzbl %al,%eax
801060bc:	29 c2                	sub    %eax,%edx
801060be:	89 d0                	mov    %edx,%eax
}
801060c0:	5d                   	pop    %ebp
801060c1:	c3                   	ret    

801060c2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801060c2:	55                   	push   %ebp
801060c3:	89 e5                	mov    %esp,%ebp
801060c5:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801060c8:	8b 45 08             	mov    0x8(%ebp),%eax
801060cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801060ce:	90                   	nop
801060cf:	8b 45 10             	mov    0x10(%ebp),%eax
801060d2:	8d 50 ff             	lea    -0x1(%eax),%edx
801060d5:	89 55 10             	mov    %edx,0x10(%ebp)
801060d8:	85 c0                	test   %eax,%eax
801060da:	7e 2c                	jle    80106108 <strncpy+0x46>
801060dc:	8b 45 08             	mov    0x8(%ebp),%eax
801060df:	8d 50 01             	lea    0x1(%eax),%edx
801060e2:	89 55 08             	mov    %edx,0x8(%ebp)
801060e5:	8b 55 0c             	mov    0xc(%ebp),%edx
801060e8:	8d 4a 01             	lea    0x1(%edx),%ecx
801060eb:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801060ee:	0f b6 12             	movzbl (%edx),%edx
801060f1:	88 10                	mov    %dl,(%eax)
801060f3:	0f b6 00             	movzbl (%eax),%eax
801060f6:	84 c0                	test   %al,%al
801060f8:	75 d5                	jne    801060cf <strncpy+0xd>
    ;
  while(n-- > 0)
801060fa:	eb 0c                	jmp    80106108 <strncpy+0x46>
    *s++ = 0;
801060fc:	8b 45 08             	mov    0x8(%ebp),%eax
801060ff:	8d 50 01             	lea    0x1(%eax),%edx
80106102:	89 55 08             	mov    %edx,0x8(%ebp)
80106105:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80106108:	8b 45 10             	mov    0x10(%ebp),%eax
8010610b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010610e:	89 55 10             	mov    %edx,0x10(%ebp)
80106111:	85 c0                	test   %eax,%eax
80106113:	7f e7                	jg     801060fc <strncpy+0x3a>
    *s++ = 0;
  return os;
80106115:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106118:	c9                   	leave  
80106119:	c3                   	ret    

8010611a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010611a:	55                   	push   %ebp
8010611b:	89 e5                	mov    %esp,%ebp
8010611d:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106120:	8b 45 08             	mov    0x8(%ebp),%eax
80106123:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80106126:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010612a:	7f 05                	jg     80106131 <safestrcpy+0x17>
    return os;
8010612c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010612f:	eb 31                	jmp    80106162 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80106131:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106135:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106139:	7e 1e                	jle    80106159 <safestrcpy+0x3f>
8010613b:	8b 45 08             	mov    0x8(%ebp),%eax
8010613e:	8d 50 01             	lea    0x1(%eax),%edx
80106141:	89 55 08             	mov    %edx,0x8(%ebp)
80106144:	8b 55 0c             	mov    0xc(%ebp),%edx
80106147:	8d 4a 01             	lea    0x1(%edx),%ecx
8010614a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010614d:	0f b6 12             	movzbl (%edx),%edx
80106150:	88 10                	mov    %dl,(%eax)
80106152:	0f b6 00             	movzbl (%eax),%eax
80106155:	84 c0                	test   %al,%al
80106157:	75 d8                	jne    80106131 <safestrcpy+0x17>
    ;
  *s = 0;
80106159:	8b 45 08             	mov    0x8(%ebp),%eax
8010615c:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010615f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106162:	c9                   	leave  
80106163:	c3                   	ret    

80106164 <strlen>:

int
strlen(const char *s)
{
80106164:	55                   	push   %ebp
80106165:	89 e5                	mov    %esp,%ebp
80106167:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010616a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106171:	eb 04                	jmp    80106177 <strlen+0x13>
80106173:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106177:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010617a:	8b 45 08             	mov    0x8(%ebp),%eax
8010617d:	01 d0                	add    %edx,%eax
8010617f:	0f b6 00             	movzbl (%eax),%eax
80106182:	84 c0                	test   %al,%al
80106184:	75 ed                	jne    80106173 <strlen+0xf>
    ;
  return n;
80106186:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106189:	c9                   	leave  
8010618a:	c3                   	ret    

8010618b <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010618b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010618f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80106193:	55                   	push   %ebp
  pushl %ebx
80106194:	53                   	push   %ebx
  pushl %esi
80106195:	56                   	push   %esi
  pushl %edi
80106196:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106197:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106199:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010619b:	5f                   	pop    %edi
  popl %esi
8010619c:	5e                   	pop    %esi
  popl %ebx
8010619d:	5b                   	pop    %ebx
  popl %ebp
8010619e:	5d                   	pop    %ebp
  ret
8010619f:	c3                   	ret    

801061a0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801061a0:	55                   	push   %ebp
801061a1:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
801061a3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061a9:	8b 00                	mov    (%eax),%eax
801061ab:	3b 45 08             	cmp    0x8(%ebp),%eax
801061ae:	76 12                	jbe    801061c2 <fetchint+0x22>
801061b0:	8b 45 08             	mov    0x8(%ebp),%eax
801061b3:	8d 50 04             	lea    0x4(%eax),%edx
801061b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061bc:	8b 00                	mov    (%eax),%eax
801061be:	39 c2                	cmp    %eax,%edx
801061c0:	76 07                	jbe    801061c9 <fetchint+0x29>
    return -1;
801061c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061c7:	eb 0f                	jmp    801061d8 <fetchint+0x38>
  *ip = *(int*)(addr);
801061c9:	8b 45 08             	mov    0x8(%ebp),%eax
801061cc:	8b 10                	mov    (%eax),%edx
801061ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801061d1:	89 10                	mov    %edx,(%eax)
  return 0;
801061d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061d8:	5d                   	pop    %ebp
801061d9:	c3                   	ret    

801061da <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801061da:	55                   	push   %ebp
801061db:	89 e5                	mov    %esp,%ebp
801061dd:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801061e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801061e6:	8b 00                	mov    (%eax),%eax
801061e8:	3b 45 08             	cmp    0x8(%ebp),%eax
801061eb:	77 07                	ja     801061f4 <fetchstr+0x1a>
    return -1;
801061ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f2:	eb 46                	jmp    8010623a <fetchstr+0x60>
  *pp = (char*)addr;
801061f4:	8b 55 08             	mov    0x8(%ebp),%edx
801061f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801061fa:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801061fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106202:	8b 00                	mov    (%eax),%eax
80106204:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80106207:	8b 45 0c             	mov    0xc(%ebp),%eax
8010620a:	8b 00                	mov    (%eax),%eax
8010620c:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010620f:	eb 1c                	jmp    8010622d <fetchstr+0x53>
    if(*s == 0)
80106211:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106214:	0f b6 00             	movzbl (%eax),%eax
80106217:	84 c0                	test   %al,%al
80106219:	75 0e                	jne    80106229 <fetchstr+0x4f>
      return s - *pp;
8010621b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010621e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106221:	8b 00                	mov    (%eax),%eax
80106223:	29 c2                	sub    %eax,%edx
80106225:	89 d0                	mov    %edx,%eax
80106227:	eb 11                	jmp    8010623a <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80106229:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010622d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106230:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106233:	72 dc                	jb     80106211 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80106235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010623a:	c9                   	leave  
8010623b:	c3                   	ret    

8010623c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010623c:	55                   	push   %ebp
8010623d:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
8010623f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106245:	8b 40 18             	mov    0x18(%eax),%eax
80106248:	8b 40 44             	mov    0x44(%eax),%eax
8010624b:	8b 55 08             	mov    0x8(%ebp),%edx
8010624e:	c1 e2 02             	shl    $0x2,%edx
80106251:	01 d0                	add    %edx,%eax
80106253:	83 c0 04             	add    $0x4,%eax
80106256:	ff 75 0c             	pushl  0xc(%ebp)
80106259:	50                   	push   %eax
8010625a:	e8 41 ff ff ff       	call   801061a0 <fetchint>
8010625f:	83 c4 08             	add    $0x8,%esp
}
80106262:	c9                   	leave  
80106263:	c3                   	ret    

80106264 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106264:	55                   	push   %ebp
80106265:	89 e5                	mov    %esp,%ebp
80106267:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010626a:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010626d:	50                   	push   %eax
8010626e:	ff 75 08             	pushl  0x8(%ebp)
80106271:	e8 c6 ff ff ff       	call   8010623c <argint>
80106276:	83 c4 08             	add    $0x8,%esp
80106279:	85 c0                	test   %eax,%eax
8010627b:	79 07                	jns    80106284 <argptr+0x20>
    return -1;
8010627d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106282:	eb 3b                	jmp    801062bf <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80106284:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010628a:	8b 00                	mov    (%eax),%eax
8010628c:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010628f:	39 d0                	cmp    %edx,%eax
80106291:	76 16                	jbe    801062a9 <argptr+0x45>
80106293:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106296:	89 c2                	mov    %eax,%edx
80106298:	8b 45 10             	mov    0x10(%ebp),%eax
8010629b:	01 c2                	add    %eax,%edx
8010629d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062a3:	8b 00                	mov    (%eax),%eax
801062a5:	39 c2                	cmp    %eax,%edx
801062a7:	76 07                	jbe    801062b0 <argptr+0x4c>
    return -1;
801062a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062ae:	eb 0f                	jmp    801062bf <argptr+0x5b>
  *pp = (char*)i;
801062b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062b3:	89 c2                	mov    %eax,%edx
801062b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801062b8:	89 10                	mov    %edx,(%eax)
  return 0;
801062ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062bf:	c9                   	leave  
801062c0:	c3                   	ret    

801062c1 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801062c1:	55                   	push   %ebp
801062c2:	89 e5                	mov    %esp,%ebp
801062c4:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801062c7:	8d 45 fc             	lea    -0x4(%ebp),%eax
801062ca:	50                   	push   %eax
801062cb:	ff 75 08             	pushl  0x8(%ebp)
801062ce:	e8 69 ff ff ff       	call   8010623c <argint>
801062d3:	83 c4 08             	add    $0x8,%esp
801062d6:	85 c0                	test   %eax,%eax
801062d8:	79 07                	jns    801062e1 <argstr+0x20>
    return -1;
801062da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062df:	eb 0f                	jmp    801062f0 <argstr+0x2f>
  return fetchstr(addr, pp);
801062e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062e4:	ff 75 0c             	pushl  0xc(%ebp)
801062e7:	50                   	push   %eax
801062e8:	e8 ed fe ff ff       	call   801061da <fetchstr>
801062ed:	83 c4 08             	add    $0x8,%esp
}
801062f0:	c9                   	leave  
801062f1:	c3                   	ret    

801062f2 <syscall>:
};
#endif

void
syscall(void)
{
801062f2:	55                   	push   %ebp
801062f3:	89 e5                	mov    %esp,%ebp
801062f5:	53                   	push   %ebx
801062f6:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801062f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062ff:	8b 40 18             	mov    0x18(%eax),%eax
80106302:	8b 40 1c             	mov    0x1c(%eax),%eax
80106305:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80106308:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010630c:	7e 30                	jle    8010633e <syscall+0x4c>
8010630e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106311:	83 f8 1d             	cmp    $0x1d,%eax
80106314:	77 28                	ja     8010633e <syscall+0x4c>
80106316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106319:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106320:	85 c0                	test   %eax,%eax
80106322:	74 1a                	je     8010633e <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80106324:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010632a:	8b 58 18             	mov    0x18(%eax),%ebx
8010632d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106330:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80106337:	ff d0                	call   *%eax
80106339:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010633c:	eb 34                	jmp    80106372 <syscall+0x80>
    #ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
    #endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
8010633e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106344:	8d 50 6c             	lea    0x6c(%eax),%edx
80106347:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
    #ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
    #endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
8010634d:	8b 40 10             	mov    0x10(%eax),%eax
80106350:	ff 75 f4             	pushl  -0xc(%ebp)
80106353:	52                   	push   %edx
80106354:	50                   	push   %eax
80106355:	68 1c 9a 10 80       	push   $0x80109a1c
8010635a:	e8 67 a0 ff ff       	call   801003c6 <cprintf>
8010635f:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80106362:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106368:	8b 40 18             	mov    0x18(%eax),%eax
8010636b:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106372:	90                   	nop
80106373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80106376:	c9                   	leave  
80106377:	c3                   	ret    

80106378 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106378:	55                   	push   %ebp
80106379:	89 e5                	mov    %esp,%ebp
8010637b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010637e:	83 ec 08             	sub    $0x8,%esp
80106381:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106384:	50                   	push   %eax
80106385:	ff 75 08             	pushl  0x8(%ebp)
80106388:	e8 af fe ff ff       	call   8010623c <argint>
8010638d:	83 c4 10             	add    $0x10,%esp
80106390:	85 c0                	test   %eax,%eax
80106392:	79 07                	jns    8010639b <argfd+0x23>
    return -1;
80106394:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106399:	eb 50                	jmp    801063eb <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010639b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639e:	85 c0                	test   %eax,%eax
801063a0:	78 21                	js     801063c3 <argfd+0x4b>
801063a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a5:	83 f8 0f             	cmp    $0xf,%eax
801063a8:	7f 19                	jg     801063c3 <argfd+0x4b>
801063aa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063b3:	83 c2 08             	add    $0x8,%edx
801063b6:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801063ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801063bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063c1:	75 07                	jne    801063ca <argfd+0x52>
    return -1;
801063c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c8:	eb 21                	jmp    801063eb <argfd+0x73>
  if(pfd)
801063ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801063ce:	74 08                	je     801063d8 <argfd+0x60>
    *pfd = fd;
801063d0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801063d6:	89 10                	mov    %edx,(%eax)
  if(pf)
801063d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801063dc:	74 08                	je     801063e6 <argfd+0x6e>
    *pf = f;
801063de:	8b 45 10             	mov    0x10(%ebp),%eax
801063e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063e4:	89 10                	mov    %edx,(%eax)
  return 0;
801063e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063eb:	c9                   	leave  
801063ec:	c3                   	ret    

801063ed <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801063ed:	55                   	push   %ebp
801063ee:	89 e5                	mov    %esp,%ebp
801063f0:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801063f3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801063fa:	eb 30                	jmp    8010642c <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801063fc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106402:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106405:	83 c2 08             	add    $0x8,%edx
80106408:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010640c:	85 c0                	test   %eax,%eax
8010640e:	75 18                	jne    80106428 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80106410:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106416:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106419:	8d 4a 08             	lea    0x8(%edx),%ecx
8010641c:	8b 55 08             	mov    0x8(%ebp),%edx
8010641f:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80106423:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106426:	eb 0f                	jmp    80106437 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80106428:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010642c:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80106430:	7e ca                	jle    801063fc <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80106432:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106437:	c9                   	leave  
80106438:	c3                   	ret    

80106439 <sys_dup>:

int
sys_dup(void)
{
80106439:	55                   	push   %ebp
8010643a:	89 e5                	mov    %esp,%ebp
8010643c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010643f:	83 ec 04             	sub    $0x4,%esp
80106442:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106445:	50                   	push   %eax
80106446:	6a 00                	push   $0x0
80106448:	6a 00                	push   $0x0
8010644a:	e8 29 ff ff ff       	call   80106378 <argfd>
8010644f:	83 c4 10             	add    $0x10,%esp
80106452:	85 c0                	test   %eax,%eax
80106454:	79 07                	jns    8010645d <sys_dup+0x24>
    return -1;
80106456:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010645b:	eb 31                	jmp    8010648e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
8010645d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106460:	83 ec 0c             	sub    $0xc,%esp
80106463:	50                   	push   %eax
80106464:	e8 84 ff ff ff       	call   801063ed <fdalloc>
80106469:	83 c4 10             	add    $0x10,%esp
8010646c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010646f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106473:	79 07                	jns    8010647c <sys_dup+0x43>
    return -1;
80106475:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647a:	eb 12                	jmp    8010648e <sys_dup+0x55>
  filedup(f);
8010647c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647f:	83 ec 0c             	sub    $0xc,%esp
80106482:	50                   	push   %eax
80106483:	e8 2a ac ff ff       	call   801010b2 <filedup>
80106488:	83 c4 10             	add    $0x10,%esp
  return fd;
8010648b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010648e:	c9                   	leave  
8010648f:	c3                   	ret    

80106490 <sys_read>:

int
sys_read(void)
{
80106490:	55                   	push   %ebp
80106491:	89 e5                	mov    %esp,%ebp
80106493:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106496:	83 ec 04             	sub    $0x4,%esp
80106499:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010649c:	50                   	push   %eax
8010649d:	6a 00                	push   $0x0
8010649f:	6a 00                	push   $0x0
801064a1:	e8 d2 fe ff ff       	call   80106378 <argfd>
801064a6:	83 c4 10             	add    $0x10,%esp
801064a9:	85 c0                	test   %eax,%eax
801064ab:	78 2e                	js     801064db <sys_read+0x4b>
801064ad:	83 ec 08             	sub    $0x8,%esp
801064b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064b3:	50                   	push   %eax
801064b4:	6a 02                	push   $0x2
801064b6:	e8 81 fd ff ff       	call   8010623c <argint>
801064bb:	83 c4 10             	add    $0x10,%esp
801064be:	85 c0                	test   %eax,%eax
801064c0:	78 19                	js     801064db <sys_read+0x4b>
801064c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c5:	83 ec 04             	sub    $0x4,%esp
801064c8:	50                   	push   %eax
801064c9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064cc:	50                   	push   %eax
801064cd:	6a 01                	push   $0x1
801064cf:	e8 90 fd ff ff       	call   80106264 <argptr>
801064d4:	83 c4 10             	add    $0x10,%esp
801064d7:	85 c0                	test   %eax,%eax
801064d9:	79 07                	jns    801064e2 <sys_read+0x52>
    return -1;
801064db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e0:	eb 17                	jmp    801064f9 <sys_read+0x69>
  return fileread(f, p, n);
801064e2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801064e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801064e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064eb:	83 ec 04             	sub    $0x4,%esp
801064ee:	51                   	push   %ecx
801064ef:	52                   	push   %edx
801064f0:	50                   	push   %eax
801064f1:	e8 4c ad ff ff       	call   80101242 <fileread>
801064f6:	83 c4 10             	add    $0x10,%esp
}
801064f9:	c9                   	leave  
801064fa:	c3                   	ret    

801064fb <sys_write>:

int
sys_write(void)
{
801064fb:	55                   	push   %ebp
801064fc:	89 e5                	mov    %esp,%ebp
801064fe:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106501:	83 ec 04             	sub    $0x4,%esp
80106504:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106507:	50                   	push   %eax
80106508:	6a 00                	push   $0x0
8010650a:	6a 00                	push   $0x0
8010650c:	e8 67 fe ff ff       	call   80106378 <argfd>
80106511:	83 c4 10             	add    $0x10,%esp
80106514:	85 c0                	test   %eax,%eax
80106516:	78 2e                	js     80106546 <sys_write+0x4b>
80106518:	83 ec 08             	sub    $0x8,%esp
8010651b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010651e:	50                   	push   %eax
8010651f:	6a 02                	push   $0x2
80106521:	e8 16 fd ff ff       	call   8010623c <argint>
80106526:	83 c4 10             	add    $0x10,%esp
80106529:	85 c0                	test   %eax,%eax
8010652b:	78 19                	js     80106546 <sys_write+0x4b>
8010652d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106530:	83 ec 04             	sub    $0x4,%esp
80106533:	50                   	push   %eax
80106534:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106537:	50                   	push   %eax
80106538:	6a 01                	push   $0x1
8010653a:	e8 25 fd ff ff       	call   80106264 <argptr>
8010653f:	83 c4 10             	add    $0x10,%esp
80106542:	85 c0                	test   %eax,%eax
80106544:	79 07                	jns    8010654d <sys_write+0x52>
    return -1;
80106546:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654b:	eb 17                	jmp    80106564 <sys_write+0x69>
  return filewrite(f, p, n);
8010654d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106550:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106553:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106556:	83 ec 04             	sub    $0x4,%esp
80106559:	51                   	push   %ecx
8010655a:	52                   	push   %edx
8010655b:	50                   	push   %eax
8010655c:	e8 99 ad ff ff       	call   801012fa <filewrite>
80106561:	83 c4 10             	add    $0x10,%esp
}
80106564:	c9                   	leave  
80106565:	c3                   	ret    

80106566 <sys_close>:

int
sys_close(void)
{
80106566:	55                   	push   %ebp
80106567:	89 e5                	mov    %esp,%ebp
80106569:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010656c:	83 ec 04             	sub    $0x4,%esp
8010656f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106572:	50                   	push   %eax
80106573:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106576:	50                   	push   %eax
80106577:	6a 00                	push   $0x0
80106579:	e8 fa fd ff ff       	call   80106378 <argfd>
8010657e:	83 c4 10             	add    $0x10,%esp
80106581:	85 c0                	test   %eax,%eax
80106583:	79 07                	jns    8010658c <sys_close+0x26>
    return -1;
80106585:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658a:	eb 28                	jmp    801065b4 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010658c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106595:	83 c2 08             	add    $0x8,%edx
80106598:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010659f:	00 
  fileclose(f);
801065a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a3:	83 ec 0c             	sub    $0xc,%esp
801065a6:	50                   	push   %eax
801065a7:	e8 57 ab ff ff       	call   80101103 <fileclose>
801065ac:	83 c4 10             	add    $0x10,%esp
  return 0;
801065af:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065b4:	c9                   	leave  
801065b5:	c3                   	ret    

801065b6 <sys_fstat>:

int
sys_fstat(void)
{
801065b6:	55                   	push   %ebp
801065b7:	89 e5                	mov    %esp,%ebp
801065b9:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801065bc:	83 ec 04             	sub    $0x4,%esp
801065bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
801065c2:	50                   	push   %eax
801065c3:	6a 00                	push   $0x0
801065c5:	6a 00                	push   $0x0
801065c7:	e8 ac fd ff ff       	call   80106378 <argfd>
801065cc:	83 c4 10             	add    $0x10,%esp
801065cf:	85 c0                	test   %eax,%eax
801065d1:	78 17                	js     801065ea <sys_fstat+0x34>
801065d3:	83 ec 04             	sub    $0x4,%esp
801065d6:	6a 14                	push   $0x14
801065d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065db:	50                   	push   %eax
801065dc:	6a 01                	push   $0x1
801065de:	e8 81 fc ff ff       	call   80106264 <argptr>
801065e3:	83 c4 10             	add    $0x10,%esp
801065e6:	85 c0                	test   %eax,%eax
801065e8:	79 07                	jns    801065f1 <sys_fstat+0x3b>
    return -1;
801065ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065ef:	eb 13                	jmp    80106604 <sys_fstat+0x4e>
  return filestat(f, st);
801065f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065f7:	83 ec 08             	sub    $0x8,%esp
801065fa:	52                   	push   %edx
801065fb:	50                   	push   %eax
801065fc:	e8 ea ab ff ff       	call   801011eb <filestat>
80106601:	83 c4 10             	add    $0x10,%esp
}
80106604:	c9                   	leave  
80106605:	c3                   	ret    

80106606 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80106606:	55                   	push   %ebp
80106607:	89 e5                	mov    %esp,%ebp
80106609:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010660c:	83 ec 08             	sub    $0x8,%esp
8010660f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106612:	50                   	push   %eax
80106613:	6a 00                	push   $0x0
80106615:	e8 a7 fc ff ff       	call   801062c1 <argstr>
8010661a:	83 c4 10             	add    $0x10,%esp
8010661d:	85 c0                	test   %eax,%eax
8010661f:	78 15                	js     80106636 <sys_link+0x30>
80106621:	83 ec 08             	sub    $0x8,%esp
80106624:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106627:	50                   	push   %eax
80106628:	6a 01                	push   $0x1
8010662a:	e8 92 fc ff ff       	call   801062c1 <argstr>
8010662f:	83 c4 10             	add    $0x10,%esp
80106632:	85 c0                	test   %eax,%eax
80106634:	79 0a                	jns    80106640 <sys_link+0x3a>
    return -1;
80106636:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010663b:	e9 68 01 00 00       	jmp    801067a8 <sys_link+0x1a2>

  begin_op();
80106640:	e8 ba cf ff ff       	call   801035ff <begin_op>
  if((ip = namei(old)) == 0){
80106645:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106648:	83 ec 0c             	sub    $0xc,%esp
8010664b:	50                   	push   %eax
8010664c:	e8 89 bf ff ff       	call   801025da <namei>
80106651:	83 c4 10             	add    $0x10,%esp
80106654:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106657:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010665b:	75 0f                	jne    8010666c <sys_link+0x66>
    end_op();
8010665d:	e8 29 d0 ff ff       	call   8010368b <end_op>
    return -1;
80106662:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106667:	e9 3c 01 00 00       	jmp    801067a8 <sys_link+0x1a2>
  }

  ilock(ip);
8010666c:	83 ec 0c             	sub    $0xc,%esp
8010666f:	ff 75 f4             	pushl  -0xc(%ebp)
80106672:	e8 a5 b3 ff ff       	call   80101a1c <ilock>
80106677:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010667a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010667d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106681:	66 83 f8 01          	cmp    $0x1,%ax
80106685:	75 1d                	jne    801066a4 <sys_link+0x9e>
    iunlockput(ip);
80106687:	83 ec 0c             	sub    $0xc,%esp
8010668a:	ff 75 f4             	pushl  -0xc(%ebp)
8010668d:	e8 4a b6 ff ff       	call   80101cdc <iunlockput>
80106692:	83 c4 10             	add    $0x10,%esp
    end_op();
80106695:	e8 f1 cf ff ff       	call   8010368b <end_op>
    return -1;
8010669a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010669f:	e9 04 01 00 00       	jmp    801067a8 <sys_link+0x1a2>
  }

  ip->nlink++;
801066a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a7:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801066ab:	83 c0 01             	add    $0x1,%eax
801066ae:	89 c2                	mov    %eax,%edx
801066b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066b3:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801066b7:	83 ec 0c             	sub    $0xc,%esp
801066ba:	ff 75 f4             	pushl  -0xc(%ebp)
801066bd:	e8 80 b1 ff ff       	call   80101842 <iupdate>
801066c2:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801066c5:	83 ec 0c             	sub    $0xc,%esp
801066c8:	ff 75 f4             	pushl  -0xc(%ebp)
801066cb:	e8 aa b4 ff ff       	call   80101b7a <iunlock>
801066d0:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801066d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801066d6:	83 ec 08             	sub    $0x8,%esp
801066d9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801066dc:	52                   	push   %edx
801066dd:	50                   	push   %eax
801066de:	e8 13 bf ff ff       	call   801025f6 <nameiparent>
801066e3:	83 c4 10             	add    $0x10,%esp
801066e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066ed:	74 71                	je     80106760 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801066ef:	83 ec 0c             	sub    $0xc,%esp
801066f2:	ff 75 f0             	pushl  -0x10(%ebp)
801066f5:	e8 22 b3 ff ff       	call   80101a1c <ilock>
801066fa:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801066fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106700:	8b 10                	mov    (%eax),%edx
80106702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106705:	8b 00                	mov    (%eax),%eax
80106707:	39 c2                	cmp    %eax,%edx
80106709:	75 1d                	jne    80106728 <sys_link+0x122>
8010670b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670e:	8b 40 04             	mov    0x4(%eax),%eax
80106711:	83 ec 04             	sub    $0x4,%esp
80106714:	50                   	push   %eax
80106715:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80106718:	50                   	push   %eax
80106719:	ff 75 f0             	pushl  -0x10(%ebp)
8010671c:	e8 1d bc ff ff       	call   8010233e <dirlink>
80106721:	83 c4 10             	add    $0x10,%esp
80106724:	85 c0                	test   %eax,%eax
80106726:	79 10                	jns    80106738 <sys_link+0x132>
    iunlockput(dp);
80106728:	83 ec 0c             	sub    $0xc,%esp
8010672b:	ff 75 f0             	pushl  -0x10(%ebp)
8010672e:	e8 a9 b5 ff ff       	call   80101cdc <iunlockput>
80106733:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106736:	eb 29                	jmp    80106761 <sys_link+0x15b>
  }
  iunlockput(dp);
80106738:	83 ec 0c             	sub    $0xc,%esp
8010673b:	ff 75 f0             	pushl  -0x10(%ebp)
8010673e:	e8 99 b5 ff ff       	call   80101cdc <iunlockput>
80106743:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106746:	83 ec 0c             	sub    $0xc,%esp
80106749:	ff 75 f4             	pushl  -0xc(%ebp)
8010674c:	e8 9b b4 ff ff       	call   80101bec <iput>
80106751:	83 c4 10             	add    $0x10,%esp

  end_op();
80106754:	e8 32 cf ff ff       	call   8010368b <end_op>

  return 0;
80106759:	b8 00 00 00 00       	mov    $0x0,%eax
8010675e:	eb 48                	jmp    801067a8 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106760:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106761:	83 ec 0c             	sub    $0xc,%esp
80106764:	ff 75 f4             	pushl  -0xc(%ebp)
80106767:	e8 b0 b2 ff ff       	call   80101a1c <ilock>
8010676c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010676f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106772:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106776:	83 e8 01             	sub    $0x1,%eax
80106779:	89 c2                	mov    %eax,%edx
8010677b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106782:	83 ec 0c             	sub    $0xc,%esp
80106785:	ff 75 f4             	pushl  -0xc(%ebp)
80106788:	e8 b5 b0 ff ff       	call   80101842 <iupdate>
8010678d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106790:	83 ec 0c             	sub    $0xc,%esp
80106793:	ff 75 f4             	pushl  -0xc(%ebp)
80106796:	e8 41 b5 ff ff       	call   80101cdc <iunlockput>
8010679b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010679e:	e8 e8 ce ff ff       	call   8010368b <end_op>
  return -1;
801067a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801067a8:	c9                   	leave  
801067a9:	c3                   	ret    

801067aa <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801067aa:	55                   	push   %ebp
801067ab:	89 e5                	mov    %esp,%ebp
801067ad:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801067b0:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801067b7:	eb 40                	jmp    801067f9 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801067b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067bc:	6a 10                	push   $0x10
801067be:	50                   	push   %eax
801067bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801067c2:	50                   	push   %eax
801067c3:	ff 75 08             	pushl  0x8(%ebp)
801067c6:	e8 bf b7 ff ff       	call   80101f8a <readi>
801067cb:	83 c4 10             	add    $0x10,%esp
801067ce:	83 f8 10             	cmp    $0x10,%eax
801067d1:	74 0d                	je     801067e0 <isdirempty+0x36>
      panic("isdirempty: readi");
801067d3:	83 ec 0c             	sub    $0xc,%esp
801067d6:	68 38 9a 10 80       	push   $0x80109a38
801067db:	e8 86 9d ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801067e0:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801067e4:	66 85 c0             	test   %ax,%ax
801067e7:	74 07                	je     801067f0 <isdirempty+0x46>
      return 0;
801067e9:	b8 00 00 00 00       	mov    $0x0,%eax
801067ee:	eb 1b                	jmp    8010680b <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801067f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067f3:	83 c0 10             	add    $0x10,%eax
801067f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067f9:	8b 45 08             	mov    0x8(%ebp),%eax
801067fc:	8b 50 18             	mov    0x18(%eax),%edx
801067ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106802:	39 c2                	cmp    %eax,%edx
80106804:	77 b3                	ja     801067b9 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106806:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010680b:	c9                   	leave  
8010680c:	c3                   	ret    

8010680d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
8010680d:	55                   	push   %ebp
8010680e:	89 e5                	mov    %esp,%ebp
80106810:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80106813:	83 ec 08             	sub    $0x8,%esp
80106816:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106819:	50                   	push   %eax
8010681a:	6a 00                	push   $0x0
8010681c:	e8 a0 fa ff ff       	call   801062c1 <argstr>
80106821:	83 c4 10             	add    $0x10,%esp
80106824:	85 c0                	test   %eax,%eax
80106826:	79 0a                	jns    80106832 <sys_unlink+0x25>
    return -1;
80106828:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010682d:	e9 bc 01 00 00       	jmp    801069ee <sys_unlink+0x1e1>

  begin_op();
80106832:	e8 c8 cd ff ff       	call   801035ff <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106837:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010683a:	83 ec 08             	sub    $0x8,%esp
8010683d:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106840:	52                   	push   %edx
80106841:	50                   	push   %eax
80106842:	e8 af bd ff ff       	call   801025f6 <nameiparent>
80106847:	83 c4 10             	add    $0x10,%esp
8010684a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010684d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106851:	75 0f                	jne    80106862 <sys_unlink+0x55>
    end_op();
80106853:	e8 33 ce ff ff       	call   8010368b <end_op>
    return -1;
80106858:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685d:	e9 8c 01 00 00       	jmp    801069ee <sys_unlink+0x1e1>
  }

  ilock(dp);
80106862:	83 ec 0c             	sub    $0xc,%esp
80106865:	ff 75 f4             	pushl  -0xc(%ebp)
80106868:	e8 af b1 ff ff       	call   80101a1c <ilock>
8010686d:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106870:	83 ec 08             	sub    $0x8,%esp
80106873:	68 4a 9a 10 80       	push   $0x80109a4a
80106878:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010687b:	50                   	push   %eax
8010687c:	e8 e8 b9 ff ff       	call   80102269 <namecmp>
80106881:	83 c4 10             	add    $0x10,%esp
80106884:	85 c0                	test   %eax,%eax
80106886:	0f 84 4a 01 00 00    	je     801069d6 <sys_unlink+0x1c9>
8010688c:	83 ec 08             	sub    $0x8,%esp
8010688f:	68 4c 9a 10 80       	push   $0x80109a4c
80106894:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106897:	50                   	push   %eax
80106898:	e8 cc b9 ff ff       	call   80102269 <namecmp>
8010689d:	83 c4 10             	add    $0x10,%esp
801068a0:	85 c0                	test   %eax,%eax
801068a2:	0f 84 2e 01 00 00    	je     801069d6 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801068a8:	83 ec 04             	sub    $0x4,%esp
801068ab:	8d 45 c8             	lea    -0x38(%ebp),%eax
801068ae:	50                   	push   %eax
801068af:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801068b2:	50                   	push   %eax
801068b3:	ff 75 f4             	pushl  -0xc(%ebp)
801068b6:	e8 c9 b9 ff ff       	call   80102284 <dirlookup>
801068bb:	83 c4 10             	add    $0x10,%esp
801068be:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068c5:	0f 84 0a 01 00 00    	je     801069d5 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801068cb:	83 ec 0c             	sub    $0xc,%esp
801068ce:	ff 75 f0             	pushl  -0x10(%ebp)
801068d1:	e8 46 b1 ff ff       	call   80101a1c <ilock>
801068d6:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801068d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068dc:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801068e0:	66 85 c0             	test   %ax,%ax
801068e3:	7f 0d                	jg     801068f2 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801068e5:	83 ec 0c             	sub    $0xc,%esp
801068e8:	68 4f 9a 10 80       	push   $0x80109a4f
801068ed:	e8 74 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801068f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068f5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801068f9:	66 83 f8 01          	cmp    $0x1,%ax
801068fd:	75 25                	jne    80106924 <sys_unlink+0x117>
801068ff:	83 ec 0c             	sub    $0xc,%esp
80106902:	ff 75 f0             	pushl  -0x10(%ebp)
80106905:	e8 a0 fe ff ff       	call   801067aa <isdirempty>
8010690a:	83 c4 10             	add    $0x10,%esp
8010690d:	85 c0                	test   %eax,%eax
8010690f:	75 13                	jne    80106924 <sys_unlink+0x117>
    iunlockput(ip);
80106911:	83 ec 0c             	sub    $0xc,%esp
80106914:	ff 75 f0             	pushl  -0x10(%ebp)
80106917:	e8 c0 b3 ff ff       	call   80101cdc <iunlockput>
8010691c:	83 c4 10             	add    $0x10,%esp
    goto bad;
8010691f:	e9 b2 00 00 00       	jmp    801069d6 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106924:	83 ec 04             	sub    $0x4,%esp
80106927:	6a 10                	push   $0x10
80106929:	6a 00                	push   $0x0
8010692b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010692e:	50                   	push   %eax
8010692f:	e8 e3 f5 ff ff       	call   80105f17 <memset>
80106934:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106937:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010693a:	6a 10                	push   $0x10
8010693c:	50                   	push   %eax
8010693d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106940:	50                   	push   %eax
80106941:	ff 75 f4             	pushl  -0xc(%ebp)
80106944:	e8 98 b7 ff ff       	call   801020e1 <writei>
80106949:	83 c4 10             	add    $0x10,%esp
8010694c:	83 f8 10             	cmp    $0x10,%eax
8010694f:	74 0d                	je     8010695e <sys_unlink+0x151>
    panic("unlink: writei");
80106951:	83 ec 0c             	sub    $0xc,%esp
80106954:	68 61 9a 10 80       	push   $0x80109a61
80106959:	e8 08 9c ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
8010695e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106961:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106965:	66 83 f8 01          	cmp    $0x1,%ax
80106969:	75 21                	jne    8010698c <sys_unlink+0x17f>
    dp->nlink--;
8010696b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010696e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106972:	83 e8 01             	sub    $0x1,%eax
80106975:	89 c2                	mov    %eax,%edx
80106977:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
8010697e:	83 ec 0c             	sub    $0xc,%esp
80106981:	ff 75 f4             	pushl  -0xc(%ebp)
80106984:	e8 b9 ae ff ff       	call   80101842 <iupdate>
80106989:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010698c:	83 ec 0c             	sub    $0xc,%esp
8010698f:	ff 75 f4             	pushl  -0xc(%ebp)
80106992:	e8 45 b3 ff ff       	call   80101cdc <iunlockput>
80106997:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010699a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010699d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801069a1:	83 e8 01             	sub    $0x1,%eax
801069a4:	89 c2                	mov    %eax,%edx
801069a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a9:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
801069ad:	83 ec 0c             	sub    $0xc,%esp
801069b0:	ff 75 f0             	pushl  -0x10(%ebp)
801069b3:	e8 8a ae ff ff       	call   80101842 <iupdate>
801069b8:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801069bb:	83 ec 0c             	sub    $0xc,%esp
801069be:	ff 75 f0             	pushl  -0x10(%ebp)
801069c1:	e8 16 b3 ff ff       	call   80101cdc <iunlockput>
801069c6:	83 c4 10             	add    $0x10,%esp

  end_op();
801069c9:	e8 bd cc ff ff       	call   8010368b <end_op>

  return 0;
801069ce:	b8 00 00 00 00       	mov    $0x0,%eax
801069d3:	eb 19                	jmp    801069ee <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801069d5:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801069d6:	83 ec 0c             	sub    $0xc,%esp
801069d9:	ff 75 f4             	pushl  -0xc(%ebp)
801069dc:	e8 fb b2 ff ff       	call   80101cdc <iunlockput>
801069e1:	83 c4 10             	add    $0x10,%esp
  end_op();
801069e4:	e8 a2 cc ff ff       	call   8010368b <end_op>
  return -1;
801069e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801069ee:	c9                   	leave  
801069ef:	c3                   	ret    

801069f0 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801069f0:	55                   	push   %ebp
801069f1:	89 e5                	mov    %esp,%ebp
801069f3:	83 ec 38             	sub    $0x38,%esp
801069f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801069f9:	8b 55 10             	mov    0x10(%ebp),%edx
801069fc:	8b 45 14             	mov    0x14(%ebp),%eax
801069ff:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106a03:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106a07:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106a0b:	83 ec 08             	sub    $0x8,%esp
80106a0e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a11:	50                   	push   %eax
80106a12:	ff 75 08             	pushl  0x8(%ebp)
80106a15:	e8 dc bb ff ff       	call   801025f6 <nameiparent>
80106a1a:	83 c4 10             	add    $0x10,%esp
80106a1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a24:	75 0a                	jne    80106a30 <create+0x40>
    return 0;
80106a26:	b8 00 00 00 00       	mov    $0x0,%eax
80106a2b:	e9 90 01 00 00       	jmp    80106bc0 <create+0x1d0>
  ilock(dp);
80106a30:	83 ec 0c             	sub    $0xc,%esp
80106a33:	ff 75 f4             	pushl  -0xc(%ebp)
80106a36:	e8 e1 af ff ff       	call   80101a1c <ilock>
80106a3b:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106a3e:	83 ec 04             	sub    $0x4,%esp
80106a41:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a44:	50                   	push   %eax
80106a45:	8d 45 de             	lea    -0x22(%ebp),%eax
80106a48:	50                   	push   %eax
80106a49:	ff 75 f4             	pushl  -0xc(%ebp)
80106a4c:	e8 33 b8 ff ff       	call   80102284 <dirlookup>
80106a51:	83 c4 10             	add    $0x10,%esp
80106a54:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106a57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106a5b:	74 50                	je     80106aad <create+0xbd>
    iunlockput(dp);
80106a5d:	83 ec 0c             	sub    $0xc,%esp
80106a60:	ff 75 f4             	pushl  -0xc(%ebp)
80106a63:	e8 74 b2 ff ff       	call   80101cdc <iunlockput>
80106a68:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106a6b:	83 ec 0c             	sub    $0xc,%esp
80106a6e:	ff 75 f0             	pushl  -0x10(%ebp)
80106a71:	e8 a6 af ff ff       	call   80101a1c <ilock>
80106a76:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106a79:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106a7e:	75 15                	jne    80106a95 <create+0xa5>
80106a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a83:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106a87:	66 83 f8 02          	cmp    $0x2,%ax
80106a8b:	75 08                	jne    80106a95 <create+0xa5>
      return ip;
80106a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a90:	e9 2b 01 00 00       	jmp    80106bc0 <create+0x1d0>
    iunlockput(ip);
80106a95:	83 ec 0c             	sub    $0xc,%esp
80106a98:	ff 75 f0             	pushl  -0x10(%ebp)
80106a9b:	e8 3c b2 ff ff       	call   80101cdc <iunlockput>
80106aa0:	83 c4 10             	add    $0x10,%esp
    return 0;
80106aa3:	b8 00 00 00 00       	mov    $0x0,%eax
80106aa8:	e9 13 01 00 00       	jmp    80106bc0 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106aad:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab4:	8b 00                	mov    (%eax),%eax
80106ab6:	83 ec 08             	sub    $0x8,%esp
80106ab9:	52                   	push   %edx
80106aba:	50                   	push   %eax
80106abb:	e8 ab ac ff ff       	call   8010176b <ialloc>
80106ac0:	83 c4 10             	add    $0x10,%esp
80106ac3:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ac6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106aca:	75 0d                	jne    80106ad9 <create+0xe9>
    panic("create: ialloc");
80106acc:	83 ec 0c             	sub    $0xc,%esp
80106acf:	68 70 9a 10 80       	push   $0x80109a70
80106ad4:	e8 8d 9a ff ff       	call   80100566 <panic>

  ilock(ip);
80106ad9:	83 ec 0c             	sub    $0xc,%esp
80106adc:	ff 75 f0             	pushl  -0x10(%ebp)
80106adf:	e8 38 af ff ff       	call   80101a1c <ilock>
80106ae4:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aea:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106aee:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106af2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106af5:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106af9:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b00:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106b06:	83 ec 0c             	sub    $0xc,%esp
80106b09:	ff 75 f0             	pushl  -0x10(%ebp)
80106b0c:	e8 31 ad ff ff       	call   80101842 <iupdate>
80106b11:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106b14:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106b19:	75 6a                	jne    80106b85 <create+0x195>
    dp->nlink++;  // for ".."
80106b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b1e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b22:	83 c0 01             	add    $0x1,%eax
80106b25:	89 c2                	mov    %eax,%edx
80106b27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b2a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106b2e:	83 ec 0c             	sub    $0xc,%esp
80106b31:	ff 75 f4             	pushl  -0xc(%ebp)
80106b34:	e8 09 ad ff ff       	call   80101842 <iupdate>
80106b39:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b3f:	8b 40 04             	mov    0x4(%eax),%eax
80106b42:	83 ec 04             	sub    $0x4,%esp
80106b45:	50                   	push   %eax
80106b46:	68 4a 9a 10 80       	push   $0x80109a4a
80106b4b:	ff 75 f0             	pushl  -0x10(%ebp)
80106b4e:	e8 eb b7 ff ff       	call   8010233e <dirlink>
80106b53:	83 c4 10             	add    $0x10,%esp
80106b56:	85 c0                	test   %eax,%eax
80106b58:	78 1e                	js     80106b78 <create+0x188>
80106b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5d:	8b 40 04             	mov    0x4(%eax),%eax
80106b60:	83 ec 04             	sub    $0x4,%esp
80106b63:	50                   	push   %eax
80106b64:	68 4c 9a 10 80       	push   $0x80109a4c
80106b69:	ff 75 f0             	pushl  -0x10(%ebp)
80106b6c:	e8 cd b7 ff ff       	call   8010233e <dirlink>
80106b71:	83 c4 10             	add    $0x10,%esp
80106b74:	85 c0                	test   %eax,%eax
80106b76:	79 0d                	jns    80106b85 <create+0x195>
      panic("create dots");
80106b78:	83 ec 0c             	sub    $0xc,%esp
80106b7b:	68 7f 9a 10 80       	push   $0x80109a7f
80106b80:	e8 e1 99 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106b85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b88:	8b 40 04             	mov    0x4(%eax),%eax
80106b8b:	83 ec 04             	sub    $0x4,%esp
80106b8e:	50                   	push   %eax
80106b8f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106b92:	50                   	push   %eax
80106b93:	ff 75 f4             	pushl  -0xc(%ebp)
80106b96:	e8 a3 b7 ff ff       	call   8010233e <dirlink>
80106b9b:	83 c4 10             	add    $0x10,%esp
80106b9e:	85 c0                	test   %eax,%eax
80106ba0:	79 0d                	jns    80106baf <create+0x1bf>
    panic("create: dirlink");
80106ba2:	83 ec 0c             	sub    $0xc,%esp
80106ba5:	68 8b 9a 10 80       	push   $0x80109a8b
80106baa:	e8 b7 99 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106baf:	83 ec 0c             	sub    $0xc,%esp
80106bb2:	ff 75 f4             	pushl  -0xc(%ebp)
80106bb5:	e8 22 b1 ff ff       	call   80101cdc <iunlockput>
80106bba:	83 c4 10             	add    $0x10,%esp

  return ip;
80106bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106bc0:	c9                   	leave  
80106bc1:	c3                   	ret    

80106bc2 <sys_open>:

int
sys_open(void)
{
80106bc2:	55                   	push   %ebp
80106bc3:	89 e5                	mov    %esp,%ebp
80106bc5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106bc8:	83 ec 08             	sub    $0x8,%esp
80106bcb:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106bce:	50                   	push   %eax
80106bcf:	6a 00                	push   $0x0
80106bd1:	e8 eb f6 ff ff       	call   801062c1 <argstr>
80106bd6:	83 c4 10             	add    $0x10,%esp
80106bd9:	85 c0                	test   %eax,%eax
80106bdb:	78 15                	js     80106bf2 <sys_open+0x30>
80106bdd:	83 ec 08             	sub    $0x8,%esp
80106be0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106be3:	50                   	push   %eax
80106be4:	6a 01                	push   $0x1
80106be6:	e8 51 f6 ff ff       	call   8010623c <argint>
80106beb:	83 c4 10             	add    $0x10,%esp
80106bee:	85 c0                	test   %eax,%eax
80106bf0:	79 0a                	jns    80106bfc <sys_open+0x3a>
    return -1;
80106bf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bf7:	e9 61 01 00 00       	jmp    80106d5d <sys_open+0x19b>

  begin_op();
80106bfc:	e8 fe c9 ff ff       	call   801035ff <begin_op>

  if(omode & O_CREATE){
80106c01:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c04:	25 00 02 00 00       	and    $0x200,%eax
80106c09:	85 c0                	test   %eax,%eax
80106c0b:	74 2a                	je     80106c37 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106c0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c10:	6a 00                	push   $0x0
80106c12:	6a 00                	push   $0x0
80106c14:	6a 02                	push   $0x2
80106c16:	50                   	push   %eax
80106c17:	e8 d4 fd ff ff       	call   801069f0 <create>
80106c1c:	83 c4 10             	add    $0x10,%esp
80106c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106c22:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c26:	75 75                	jne    80106c9d <sys_open+0xdb>
      end_op();
80106c28:	e8 5e ca ff ff       	call   8010368b <end_op>
      return -1;
80106c2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c32:	e9 26 01 00 00       	jmp    80106d5d <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106c37:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106c3a:	83 ec 0c             	sub    $0xc,%esp
80106c3d:	50                   	push   %eax
80106c3e:	e8 97 b9 ff ff       	call   801025da <namei>
80106c43:	83 c4 10             	add    $0x10,%esp
80106c46:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c4d:	75 0f                	jne    80106c5e <sys_open+0x9c>
      end_op();
80106c4f:	e8 37 ca ff ff       	call   8010368b <end_op>
      return -1;
80106c54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c59:	e9 ff 00 00 00       	jmp    80106d5d <sys_open+0x19b>
    }
    ilock(ip);
80106c5e:	83 ec 0c             	sub    $0xc,%esp
80106c61:	ff 75 f4             	pushl  -0xc(%ebp)
80106c64:	e8 b3 ad ff ff       	call   80101a1c <ilock>
80106c69:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c6f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c73:	66 83 f8 01          	cmp    $0x1,%ax
80106c77:	75 24                	jne    80106c9d <sys_open+0xdb>
80106c79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c7c:	85 c0                	test   %eax,%eax
80106c7e:	74 1d                	je     80106c9d <sys_open+0xdb>
      iunlockput(ip);
80106c80:	83 ec 0c             	sub    $0xc,%esp
80106c83:	ff 75 f4             	pushl  -0xc(%ebp)
80106c86:	e8 51 b0 ff ff       	call   80101cdc <iunlockput>
80106c8b:	83 c4 10             	add    $0x10,%esp
      end_op();
80106c8e:	e8 f8 c9 ff ff       	call   8010368b <end_op>
      return -1;
80106c93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c98:	e9 c0 00 00 00       	jmp    80106d5d <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106c9d:	e8 a3 a3 ff ff       	call   80101045 <filealloc>
80106ca2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106ca5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ca9:	74 17                	je     80106cc2 <sys_open+0x100>
80106cab:	83 ec 0c             	sub    $0xc,%esp
80106cae:	ff 75 f0             	pushl  -0x10(%ebp)
80106cb1:	e8 37 f7 ff ff       	call   801063ed <fdalloc>
80106cb6:	83 c4 10             	add    $0x10,%esp
80106cb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106cbc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106cc0:	79 2e                	jns    80106cf0 <sys_open+0x12e>
    if(f)
80106cc2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cc6:	74 0e                	je     80106cd6 <sys_open+0x114>
      fileclose(f);
80106cc8:	83 ec 0c             	sub    $0xc,%esp
80106ccb:	ff 75 f0             	pushl  -0x10(%ebp)
80106cce:	e8 30 a4 ff ff       	call   80101103 <fileclose>
80106cd3:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106cd6:	83 ec 0c             	sub    $0xc,%esp
80106cd9:	ff 75 f4             	pushl  -0xc(%ebp)
80106cdc:	e8 fb af ff ff       	call   80101cdc <iunlockput>
80106ce1:	83 c4 10             	add    $0x10,%esp
    end_op();
80106ce4:	e8 a2 c9 ff ff       	call   8010368b <end_op>
    return -1;
80106ce9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cee:	eb 6d                	jmp    80106d5d <sys_open+0x19b>
  }
  iunlock(ip);
80106cf0:	83 ec 0c             	sub    $0xc,%esp
80106cf3:	ff 75 f4             	pushl  -0xc(%ebp)
80106cf6:	e8 7f ae ff ff       	call   80101b7a <iunlock>
80106cfb:	83 c4 10             	add    $0x10,%esp
  end_op();
80106cfe:	e8 88 c9 ff ff       	call   8010368b <end_op>

  f->type = FD_INODE;
80106d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d06:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d12:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106d15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d18:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d22:	83 e0 01             	and    $0x1,%eax
80106d25:	85 c0                	test   %eax,%eax
80106d27:	0f 94 c0             	sete   %al
80106d2a:	89 c2                	mov    %eax,%edx
80106d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d2f:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106d32:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d35:	83 e0 01             	and    $0x1,%eax
80106d38:	85 c0                	test   %eax,%eax
80106d3a:	75 0a                	jne    80106d46 <sys_open+0x184>
80106d3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d3f:	83 e0 02             	and    $0x2,%eax
80106d42:	85 c0                	test   %eax,%eax
80106d44:	74 07                	je     80106d4d <sys_open+0x18b>
80106d46:	b8 01 00 00 00       	mov    $0x1,%eax
80106d4b:	eb 05                	jmp    80106d52 <sys_open+0x190>
80106d4d:	b8 00 00 00 00       	mov    $0x0,%eax
80106d52:	89 c2                	mov    %eax,%edx
80106d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d57:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106d5a:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106d5d:	c9                   	leave  
80106d5e:	c3                   	ret    

80106d5f <sys_mkdir>:

int
sys_mkdir(void)
{
80106d5f:	55                   	push   %ebp
80106d60:	89 e5                	mov    %esp,%ebp
80106d62:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106d65:	e8 95 c8 ff ff       	call   801035ff <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106d6a:	83 ec 08             	sub    $0x8,%esp
80106d6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d70:	50                   	push   %eax
80106d71:	6a 00                	push   $0x0
80106d73:	e8 49 f5 ff ff       	call   801062c1 <argstr>
80106d78:	83 c4 10             	add    $0x10,%esp
80106d7b:	85 c0                	test   %eax,%eax
80106d7d:	78 1b                	js     80106d9a <sys_mkdir+0x3b>
80106d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d82:	6a 00                	push   $0x0
80106d84:	6a 00                	push   $0x0
80106d86:	6a 01                	push   $0x1
80106d88:	50                   	push   %eax
80106d89:	e8 62 fc ff ff       	call   801069f0 <create>
80106d8e:	83 c4 10             	add    $0x10,%esp
80106d91:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d94:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d98:	75 0c                	jne    80106da6 <sys_mkdir+0x47>
    end_op();
80106d9a:	e8 ec c8 ff ff       	call   8010368b <end_op>
    return -1;
80106d9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da4:	eb 18                	jmp    80106dbe <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106da6:	83 ec 0c             	sub    $0xc,%esp
80106da9:	ff 75 f4             	pushl  -0xc(%ebp)
80106dac:	e8 2b af ff ff       	call   80101cdc <iunlockput>
80106db1:	83 c4 10             	add    $0x10,%esp
  end_op();
80106db4:	e8 d2 c8 ff ff       	call   8010368b <end_op>
  return 0;
80106db9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106dbe:	c9                   	leave  
80106dbf:	c3                   	ret    

80106dc0 <sys_mknod>:

int
sys_mknod(void)
{
80106dc0:	55                   	push   %ebp
80106dc1:	89 e5                	mov    %esp,%ebp
80106dc3:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106dc6:	e8 34 c8 ff ff       	call   801035ff <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106dcb:	83 ec 08             	sub    $0x8,%esp
80106dce:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106dd1:	50                   	push   %eax
80106dd2:	6a 00                	push   $0x0
80106dd4:	e8 e8 f4 ff ff       	call   801062c1 <argstr>
80106dd9:	83 c4 10             	add    $0x10,%esp
80106ddc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ddf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106de3:	78 4f                	js     80106e34 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106de5:	83 ec 08             	sub    $0x8,%esp
80106de8:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106deb:	50                   	push   %eax
80106dec:	6a 01                	push   $0x1
80106dee:	e8 49 f4 ff ff       	call   8010623c <argint>
80106df3:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
80106df6:	85 c0                	test   %eax,%eax
80106df8:	78 3a                	js     80106e34 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106dfa:	83 ec 08             	sub    $0x8,%esp
80106dfd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106e00:	50                   	push   %eax
80106e01:	6a 02                	push   $0x2
80106e03:	e8 34 f4 ff ff       	call   8010623c <argint>
80106e08:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106e0b:	85 c0                	test   %eax,%eax
80106e0d:	78 25                	js     80106e34 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106e0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e12:	0f bf c8             	movswl %ax,%ecx
80106e15:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e18:	0f bf d0             	movswl %ax,%edx
80106e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106e1e:	51                   	push   %ecx
80106e1f:	52                   	push   %edx
80106e20:	6a 03                	push   $0x3
80106e22:	50                   	push   %eax
80106e23:	e8 c8 fb ff ff       	call   801069f0 <create>
80106e28:	83 c4 10             	add    $0x10,%esp
80106e2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106e2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106e32:	75 0c                	jne    80106e40 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106e34:	e8 52 c8 ff ff       	call   8010368b <end_op>
    return -1;
80106e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e3e:	eb 18                	jmp    80106e58 <sys_mknod+0x98>
  }
  iunlockput(ip);
80106e40:	83 ec 0c             	sub    $0xc,%esp
80106e43:	ff 75 f0             	pushl  -0x10(%ebp)
80106e46:	e8 91 ae ff ff       	call   80101cdc <iunlockput>
80106e4b:	83 c4 10             	add    $0x10,%esp
  end_op();
80106e4e:	e8 38 c8 ff ff       	call   8010368b <end_op>
  return 0;
80106e53:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e58:	c9                   	leave  
80106e59:	c3                   	ret    

80106e5a <sys_chdir>:

int
sys_chdir(void)
{
80106e5a:	55                   	push   %ebp
80106e5b:	89 e5                	mov    %esp,%ebp
80106e5d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106e60:	e8 9a c7 ff ff       	call   801035ff <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106e65:	83 ec 08             	sub    $0x8,%esp
80106e68:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e6b:	50                   	push   %eax
80106e6c:	6a 00                	push   $0x0
80106e6e:	e8 4e f4 ff ff       	call   801062c1 <argstr>
80106e73:	83 c4 10             	add    $0x10,%esp
80106e76:	85 c0                	test   %eax,%eax
80106e78:	78 18                	js     80106e92 <sys_chdir+0x38>
80106e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e7d:	83 ec 0c             	sub    $0xc,%esp
80106e80:	50                   	push   %eax
80106e81:	e8 54 b7 ff ff       	call   801025da <namei>
80106e86:	83 c4 10             	add    $0x10,%esp
80106e89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e8c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e90:	75 0c                	jne    80106e9e <sys_chdir+0x44>
    end_op();
80106e92:	e8 f4 c7 ff ff       	call   8010368b <end_op>
    return -1;
80106e97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e9c:	eb 6e                	jmp    80106f0c <sys_chdir+0xb2>
  }
  ilock(ip);
80106e9e:	83 ec 0c             	sub    $0xc,%esp
80106ea1:	ff 75 f4             	pushl  -0xc(%ebp)
80106ea4:	e8 73 ab ff ff       	call   80101a1c <ilock>
80106ea9:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eaf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106eb3:	66 83 f8 01          	cmp    $0x1,%ax
80106eb7:	74 1a                	je     80106ed3 <sys_chdir+0x79>
    iunlockput(ip);
80106eb9:	83 ec 0c             	sub    $0xc,%esp
80106ebc:	ff 75 f4             	pushl  -0xc(%ebp)
80106ebf:	e8 18 ae ff ff       	call   80101cdc <iunlockput>
80106ec4:	83 c4 10             	add    $0x10,%esp
    end_op();
80106ec7:	e8 bf c7 ff ff       	call   8010368b <end_op>
    return -1;
80106ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ed1:	eb 39                	jmp    80106f0c <sys_chdir+0xb2>
  }
  iunlock(ip);
80106ed3:	83 ec 0c             	sub    $0xc,%esp
80106ed6:	ff 75 f4             	pushl  -0xc(%ebp)
80106ed9:	e8 9c ac ff ff       	call   80101b7a <iunlock>
80106ede:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106ee1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ee7:	8b 40 68             	mov    0x68(%eax),%eax
80106eea:	83 ec 0c             	sub    $0xc,%esp
80106eed:	50                   	push   %eax
80106eee:	e8 f9 ac ff ff       	call   80101bec <iput>
80106ef3:	83 c4 10             	add    $0x10,%esp
  end_op();
80106ef6:	e8 90 c7 ff ff       	call   8010368b <end_op>
  proc->cwd = ip;
80106efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f04:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106f07:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f0c:	c9                   	leave  
80106f0d:	c3                   	ret    

80106f0e <sys_exec>:

int
sys_exec(void)
{
80106f0e:	55                   	push   %ebp
80106f0f:	89 e5                	mov    %esp,%ebp
80106f11:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106f17:	83 ec 08             	sub    $0x8,%esp
80106f1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f1d:	50                   	push   %eax
80106f1e:	6a 00                	push   $0x0
80106f20:	e8 9c f3 ff ff       	call   801062c1 <argstr>
80106f25:	83 c4 10             	add    $0x10,%esp
80106f28:	85 c0                	test   %eax,%eax
80106f2a:	78 18                	js     80106f44 <sys_exec+0x36>
80106f2c:	83 ec 08             	sub    $0x8,%esp
80106f2f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106f35:	50                   	push   %eax
80106f36:	6a 01                	push   $0x1
80106f38:	e8 ff f2 ff ff       	call   8010623c <argint>
80106f3d:	83 c4 10             	add    $0x10,%esp
80106f40:	85 c0                	test   %eax,%eax
80106f42:	79 0a                	jns    80106f4e <sys_exec+0x40>
    return -1;
80106f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f49:	e9 c6 00 00 00       	jmp    80107014 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106f4e:	83 ec 04             	sub    $0x4,%esp
80106f51:	68 80 00 00 00       	push   $0x80
80106f56:	6a 00                	push   $0x0
80106f58:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f5e:	50                   	push   %eax
80106f5f:	e8 b3 ef ff ff       	call   80105f17 <memset>
80106f64:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106f67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f71:	83 f8 1f             	cmp    $0x1f,%eax
80106f74:	76 0a                	jbe    80106f80 <sys_exec+0x72>
      return -1;
80106f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f7b:	e9 94 00 00 00       	jmp    80107014 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f83:	c1 e0 02             	shl    $0x2,%eax
80106f86:	89 c2                	mov    %eax,%edx
80106f88:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106f8e:	01 c2                	add    %eax,%edx
80106f90:	83 ec 08             	sub    $0x8,%esp
80106f93:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106f99:	50                   	push   %eax
80106f9a:	52                   	push   %edx
80106f9b:	e8 00 f2 ff ff       	call   801061a0 <fetchint>
80106fa0:	83 c4 10             	add    $0x10,%esp
80106fa3:	85 c0                	test   %eax,%eax
80106fa5:	79 07                	jns    80106fae <sys_exec+0xa0>
      return -1;
80106fa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fac:	eb 66                	jmp    80107014 <sys_exec+0x106>
    if(uarg == 0){
80106fae:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106fb4:	85 c0                	test   %eax,%eax
80106fb6:	75 27                	jne    80106fdf <sys_exec+0xd1>
      argv[i] = 0;
80106fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fbb:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106fc2:	00 00 00 00 
      break;
80106fc6:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106fc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fca:	83 ec 08             	sub    $0x8,%esp
80106fcd:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106fd3:	52                   	push   %edx
80106fd4:	50                   	push   %eax
80106fd5:	e8 49 9c ff ff       	call   80100c23 <exec>
80106fda:	83 c4 10             	add    $0x10,%esp
80106fdd:	eb 35                	jmp    80107014 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106fdf:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106fe5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106fe8:	c1 e2 02             	shl    $0x2,%edx
80106feb:	01 c2                	add    %eax,%edx
80106fed:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ff3:	83 ec 08             	sub    $0x8,%esp
80106ff6:	52                   	push   %edx
80106ff7:	50                   	push   %eax
80106ff8:	e8 dd f1 ff ff       	call   801061da <fetchstr>
80106ffd:	83 c4 10             	add    $0x10,%esp
80107000:	85 c0                	test   %eax,%eax
80107002:	79 07                	jns    8010700b <sys_exec+0xfd>
      return -1;
80107004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107009:	eb 09                	jmp    80107014 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010700b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010700f:	e9 5a ff ff ff       	jmp    80106f6e <sys_exec+0x60>
  return exec(path, argv);
}
80107014:	c9                   	leave  
80107015:	c3                   	ret    

80107016 <sys_pipe>:

int
sys_pipe(void)
{
80107016:	55                   	push   %ebp
80107017:	89 e5                	mov    %esp,%ebp
80107019:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010701c:	83 ec 04             	sub    $0x4,%esp
8010701f:	6a 08                	push   $0x8
80107021:	8d 45 ec             	lea    -0x14(%ebp),%eax
80107024:	50                   	push   %eax
80107025:	6a 00                	push   $0x0
80107027:	e8 38 f2 ff ff       	call   80106264 <argptr>
8010702c:	83 c4 10             	add    $0x10,%esp
8010702f:	85 c0                	test   %eax,%eax
80107031:	79 0a                	jns    8010703d <sys_pipe+0x27>
    return -1;
80107033:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107038:	e9 af 00 00 00       	jmp    801070ec <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
8010703d:	83 ec 08             	sub    $0x8,%esp
80107040:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80107043:	50                   	push   %eax
80107044:	8d 45 e8             	lea    -0x18(%ebp),%eax
80107047:	50                   	push   %eax
80107048:	e8 a6 d0 ff ff       	call   801040f3 <pipealloc>
8010704d:	83 c4 10             	add    $0x10,%esp
80107050:	85 c0                	test   %eax,%eax
80107052:	79 0a                	jns    8010705e <sys_pipe+0x48>
    return -1;
80107054:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107059:	e9 8e 00 00 00       	jmp    801070ec <sys_pipe+0xd6>
  fd0 = -1;
8010705e:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80107065:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107068:	83 ec 0c             	sub    $0xc,%esp
8010706b:	50                   	push   %eax
8010706c:	e8 7c f3 ff ff       	call   801063ed <fdalloc>
80107071:	83 c4 10             	add    $0x10,%esp
80107074:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107077:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010707b:	78 18                	js     80107095 <sys_pipe+0x7f>
8010707d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107080:	83 ec 0c             	sub    $0xc,%esp
80107083:	50                   	push   %eax
80107084:	e8 64 f3 ff ff       	call   801063ed <fdalloc>
80107089:	83 c4 10             	add    $0x10,%esp
8010708c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010708f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107093:	79 3f                	jns    801070d4 <sys_pipe+0xbe>
    if(fd0 >= 0)
80107095:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107099:	78 14                	js     801070af <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010709b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070a4:	83 c2 08             	add    $0x8,%edx
801070a7:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801070ae:	00 
    fileclose(rf);
801070af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801070b2:	83 ec 0c             	sub    $0xc,%esp
801070b5:	50                   	push   %eax
801070b6:	e8 48 a0 ff ff       	call   80101103 <fileclose>
801070bb:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801070be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070c1:	83 ec 0c             	sub    $0xc,%esp
801070c4:	50                   	push   %eax
801070c5:	e8 39 a0 ff ff       	call   80101103 <fileclose>
801070ca:	83 c4 10             	add    $0x10,%esp
    return -1;
801070cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d2:	eb 18                	jmp    801070ec <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801070d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070da:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801070dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070df:	8d 50 04             	lea    0x4(%eax),%edx
801070e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070e5:	89 02                	mov    %eax,(%edx)
  return 0;
801070e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070ec:	c9                   	leave  
801070ed:	c3                   	ret    

801070ee <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
801070ee:	55                   	push   %ebp
801070ef:	89 e5                	mov    %esp,%ebp
801070f1:	83 ec 08             	sub    $0x8,%esp
801070f4:	8b 55 08             	mov    0x8(%ebp),%edx
801070f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801070fa:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801070fe:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107102:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
80107106:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010710a:	66 ef                	out    %ax,(%dx)
}
8010710c:	90                   	nop
8010710d:	c9                   	leave  
8010710e:	c3                   	ret    

8010710f <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010710f:	55                   	push   %ebp
80107110:	89 e5                	mov    %esp,%ebp
80107112:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107115:	e8 75 d7 ff ff       	call   8010488f <fork>
}
8010711a:	c9                   	leave  
8010711b:	c3                   	ret    

8010711c <sys_exit>:

int
sys_exit(void)
{
8010711c:	55                   	push   %ebp
8010711d:	89 e5                	mov    %esp,%ebp
8010711f:	83 ec 08             	sub    $0x8,%esp
  exit();
80107122:	e8 33 d9 ff ff       	call   80104a5a <exit>
  return 0;  // not reached
80107127:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010712c:	c9                   	leave  
8010712d:	c3                   	ret    

8010712e <sys_wait>:

int
sys_wait(void)
{
8010712e:	55                   	push   %ebp
8010712f:	89 e5                	mov    %esp,%ebp
80107131:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107134:	e8 26 da ff ff       	call   80104b5f <wait>
}
80107139:	c9                   	leave  
8010713a:	c3                   	ret    

8010713b <sys_kill>:

int
sys_kill(void)
{
8010713b:	55                   	push   %ebp
8010713c:	89 e5                	mov    %esp,%ebp
8010713e:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107141:	83 ec 08             	sub    $0x8,%esp
80107144:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107147:	50                   	push   %eax
80107148:	6a 00                	push   $0x0
8010714a:	e8 ed f0 ff ff       	call   8010623c <argint>
8010714f:	83 c4 10             	add    $0x10,%esp
80107152:	85 c0                	test   %eax,%eax
80107154:	79 07                	jns    8010715d <sys_kill+0x22>
    return -1;
80107156:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010715b:	eb 0f                	jmp    8010716c <sys_kill+0x31>
  return kill(pid);
8010715d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107160:	83 ec 0c             	sub    $0xc,%esp
80107163:	50                   	push   %eax
80107164:	e8 ec de ff ff       	call   80105055 <kill>
80107169:	83 c4 10             	add    $0x10,%esp
}
8010716c:	c9                   	leave  
8010716d:	c3                   	ret    

8010716e <sys_getpid>:

int
sys_getpid(void)
{
8010716e:	55                   	push   %ebp
8010716f:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80107171:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107177:	8b 40 10             	mov    0x10(%eax),%eax
}
8010717a:	5d                   	pop    %ebp
8010717b:	c3                   	ret    

8010717c <sys_sbrk>:

int
sys_sbrk(void)
{
8010717c:	55                   	push   %ebp
8010717d:	89 e5                	mov    %esp,%ebp
8010717f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80107182:	83 ec 08             	sub    $0x8,%esp
80107185:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107188:	50                   	push   %eax
80107189:	6a 00                	push   $0x0
8010718b:	e8 ac f0 ff ff       	call   8010623c <argint>
80107190:	83 c4 10             	add    $0x10,%esp
80107193:	85 c0                	test   %eax,%eax
80107195:	79 07                	jns    8010719e <sys_sbrk+0x22>
    return -1;
80107197:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010719c:	eb 28                	jmp    801071c6 <sys_sbrk+0x4a>
  addr = proc->sz;
8010719e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071a4:	8b 00                	mov    (%eax),%eax
801071a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801071a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071ac:	83 ec 0c             	sub    $0xc,%esp
801071af:	50                   	push   %eax
801071b0:	e8 37 d6 ff ff       	call   801047ec <growproc>
801071b5:	83 c4 10             	add    $0x10,%esp
801071b8:	85 c0                	test   %eax,%eax
801071ba:	79 07                	jns    801071c3 <sys_sbrk+0x47>
    return -1;
801071bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071c1:	eb 03                	jmp    801071c6 <sys_sbrk+0x4a>
  return addr;
801071c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801071c6:	c9                   	leave  
801071c7:	c3                   	ret    

801071c8 <sys_sleep>:

int
sys_sleep(void)
{
801071c8:	55                   	push   %ebp
801071c9:	89 e5                	mov    %esp,%ebp
801071cb:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801071ce:	83 ec 08             	sub    $0x8,%esp
801071d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071d4:	50                   	push   %eax
801071d5:	6a 00                	push   $0x0
801071d7:	e8 60 f0 ff ff       	call   8010623c <argint>
801071dc:	83 c4 10             	add    $0x10,%esp
801071df:	85 c0                	test   %eax,%eax
801071e1:	79 07                	jns    801071ea <sys_sleep+0x22>
    return -1;
801071e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071e8:	eb 44                	jmp    8010722e <sys_sleep+0x66>
  ticks0 = ticks;
801071ea:	a1 00 67 11 80       	mov    0x80116700,%eax
801071ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801071f2:	eb 26                	jmp    8010721a <sys_sleep+0x52>
    if(proc->killed){
801071f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071fa:	8b 40 24             	mov    0x24(%eax),%eax
801071fd:	85 c0                	test   %eax,%eax
801071ff:	74 07                	je     80107208 <sys_sleep+0x40>
      return -1;
80107201:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107206:	eb 26                	jmp    8010722e <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
80107208:	83 ec 08             	sub    $0x8,%esp
8010720b:	6a 00                	push   $0x0
8010720d:	68 00 67 11 80       	push   $0x80116700
80107212:	e8 f2 dc ff ff       	call   80104f09 <sleep>
80107217:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010721a:	a1 00 67 11 80       	mov    0x80116700,%eax
8010721f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107222:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107225:	39 d0                	cmp    %edx,%eax
80107227:	72 cb                	jb     801071f4 <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80107229:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010722e:	c9                   	leave  
8010722f:	c3                   	ret    

80107230 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
80107230:	55                   	push   %ebp
80107231:	89 e5                	mov    %esp,%ebp
80107233:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
80107236:	a1 00 67 11 80       	mov    0x80116700,%eax
8010723b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
8010723e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107241:	c9                   	leave  
80107242:	c3                   	ret    

80107243 <sys_halt>:

//Turn of the computer
int
sys_halt(void){
80107243:	55                   	push   %ebp
80107244:	89 e5                	mov    %esp,%ebp
80107246:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80107249:	83 ec 0c             	sub    $0xc,%esp
8010724c:	68 9b 9a 10 80       	push   $0x80109a9b
80107251:	e8 70 91 ff ff       	call   801003c6 <cprintf>
80107256:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80107259:	83 ec 08             	sub    $0x8,%esp
8010725c:	68 00 20 00 00       	push   $0x2000
80107261:	68 04 06 00 00       	push   $0x604
80107266:	e8 83 fe ff ff       	call   801070ee <outw>
8010726b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010726e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107273:	c9                   	leave  
80107274:	c3                   	ret    

80107275 <sys_date>:

#ifdef CS333_P1
int
sys_date(void)
{
80107275:	55                   	push   %ebp
80107276:	89 e5                	mov    %esp,%ebp
80107278:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate* d;

  if (argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
8010727b:	83 ec 04             	sub    $0x4,%esp
8010727e:	6a 18                	push   $0x18
80107280:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107283:	50                   	push   %eax
80107284:	6a 00                	push   $0x0
80107286:	e8 d9 ef ff ff       	call   80106264 <argptr>
8010728b:	83 c4 10             	add    $0x10,%esp
8010728e:	85 c0                	test   %eax,%eax
80107290:	79 07                	jns    80107299 <sys_date+0x24>
    return -1;
80107292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107297:	eb 14                	jmp    801072ad <sys_date+0x38>

  cmostime(d);
80107299:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729c:	83 ec 0c             	sub    $0xc,%esp
8010729f:	50                   	push   %eax
801072a0:	e8 d5 bf ff ff       	call   8010327a <cmostime>
801072a5:	83 c4 10             	add    $0x10,%esp

  return 0;
801072a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072ad:	c9                   	leave  
801072ae:	c3                   	ret    

801072af <sys_getuid>:
#endif

#ifdef CS333_P2
int
sys_getuid(void)
{
801072af:	55                   	push   %ebp
801072b0:	89 e5                	mov    %esp,%ebp
  return proc->uid;
801072b2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072b8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801072be:	5d                   	pop    %ebp
801072bf:	c3                   	ret    

801072c0 <sys_getgid>:

int
sys_getgid(void)
{
801072c0:	55                   	push   %ebp
801072c1:	89 e5                	mov    %esp,%ebp
  return proc->gid;
801072c3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072c9:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
801072cf:	5d                   	pop    %ebp
801072d0:	c3                   	ret    

801072d1 <sys_getppid>:

int
sys_getppid(void)
{
801072d1:	55                   	push   %ebp
801072d2:	89 e5                	mov    %esp,%ebp
  return proc->parent->pid;
801072d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072da:	8b 40 14             	mov    0x14(%eax),%eax
801072dd:	8b 40 10             	mov    0x10(%eax),%eax
}
801072e0:	5d                   	pop    %ebp
801072e1:	c3                   	ret    

801072e2 <sys_setuid>:

int 
sys_setuid(void)
{
801072e2:	55                   	push   %ebp
801072e3:	89 e5                	mov    %esp,%ebp
801072e5:	83 ec 18             	sub    $0x18,%esp
  int x;

  if(argint(0, &x) < 0)
801072e8:	83 ec 08             	sub    $0x8,%esp
801072eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801072ee:	50                   	push   %eax
801072ef:	6a 00                	push   $0x0
801072f1:	e8 46 ef ff ff       	call   8010623c <argint>
801072f6:	83 c4 10             	add    $0x10,%esp
801072f9:	85 c0                	test   %eax,%eax
801072fb:	79 07                	jns    80107304 <sys_setuid+0x22>
    return -1;
801072fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107302:	eb 2c                	jmp    80107330 <sys_setuid+0x4e>

  if (x < 0 || x > 32767) return -1;
80107304:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107307:	85 c0                	test   %eax,%eax
80107309:	78 0a                	js     80107315 <sys_setuid+0x33>
8010730b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730e:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107313:	7e 07                	jle    8010731c <sys_setuid+0x3a>
80107315:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010731a:	eb 14                	jmp    80107330 <sys_setuid+0x4e>
  proc->uid = x;
8010731c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107322:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107325:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
8010732b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107330:	c9                   	leave  
80107331:	c3                   	ret    

80107332 <sys_setgid>:

int
sys_setgid(void)
{
80107332:	55                   	push   %ebp
80107333:	89 e5                	mov    %esp,%ebp
80107335:	83 ec 18             	sub    $0x18,%esp
  int x;

  if(argint(0, &x) < 0)
80107338:	83 ec 08             	sub    $0x8,%esp
8010733b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010733e:	50                   	push   %eax
8010733f:	6a 00                	push   $0x0
80107341:	e8 f6 ee ff ff       	call   8010623c <argint>
80107346:	83 c4 10             	add    $0x10,%esp
80107349:	85 c0                	test   %eax,%eax
8010734b:	79 07                	jns    80107354 <sys_setgid+0x22>
    return -1;
8010734d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107352:	eb 2c                	jmp    80107380 <sys_setgid+0x4e>

  if (x < 0 || x > 32767) return -1;
80107354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107357:	85 c0                	test   %eax,%eax
80107359:	78 0a                	js     80107365 <sys_setgid+0x33>
8010735b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010735e:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80107363:	7e 07                	jle    8010736c <sys_setgid+0x3a>
80107365:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010736a:	eb 14                	jmp    80107380 <sys_setgid+0x4e>
  proc->gid = x;
8010736c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107372:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107375:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  return 0;
8010737b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107380:	c9                   	leave  
80107381:	c3                   	ret    

80107382 <sys_getprocs>:

int
sys_getprocs(void)
{
80107382:	55                   	push   %ebp
80107383:	89 e5                	mov    %esp,%ebp
80107385:	83 ec 18             	sub    $0x18,%esp
  int max;
  struct uproc* table;

  if(argint(0, &max) < 0)
80107388:	83 ec 08             	sub    $0x8,%esp
8010738b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010738e:	50                   	push   %eax
8010738f:	6a 00                	push   $0x0
80107391:	e8 a6 ee ff ff       	call   8010623c <argint>
80107396:	83 c4 10             	add    $0x10,%esp
80107399:	85 c0                	test   %eax,%eax
8010739b:	79 07                	jns    801073a4 <sys_getprocs+0x22>
    return -1;
8010739d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073a2:	eb 31                	jmp    801073d5 <sys_getprocs+0x53>
  
  if (argptr(1, (void*)&table, sizeof(struct uproc)) < 0)
801073a4:	83 ec 04             	sub    $0x4,%esp
801073a7:	6a 5c                	push   $0x5c
801073a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073ac:	50                   	push   %eax
801073ad:	6a 01                	push   $0x1
801073af:	e8 b0 ee ff ff       	call   80106264 <argptr>
801073b4:	83 c4 10             	add    $0x10,%esp
801073b7:	85 c0                	test   %eax,%eax
801073b9:	79 07                	jns    801073c2 <sys_getprocs+0x40>
    return -1;
801073bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073c0:	eb 13                	jmp    801073d5 <sys_getprocs+0x53>

  return getprocs(max,table);
801073c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801073c8:	83 ec 08             	sub    $0x8,%esp
801073cb:	50                   	push   %eax
801073cc:	52                   	push   %edx
801073cd:	e8 8b dd ff ff       	call   8010515d <getprocs>
801073d2:	83 c4 10             	add    $0x10,%esp
}
801073d5:	c9                   	leave  
801073d6:	c3                   	ret    

801073d7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801073d7:	55                   	push   %ebp
801073d8:	89 e5                	mov    %esp,%ebp
801073da:	83 ec 08             	sub    $0x8,%esp
801073dd:	8b 55 08             	mov    0x8(%ebp),%edx
801073e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801073e3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801073e7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801073ea:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801073ee:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801073f2:	ee                   	out    %al,(%dx)
}
801073f3:	90                   	nop
801073f4:	c9                   	leave  
801073f5:	c3                   	ret    

801073f6 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801073f6:	55                   	push   %ebp
801073f7:	89 e5                	mov    %esp,%ebp
801073f9:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801073fc:	6a 34                	push   $0x34
801073fe:	6a 43                	push   $0x43
80107400:	e8 d2 ff ff ff       	call   801073d7 <outb>
80107405:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
80107408:	68 a9 00 00 00       	push   $0xa9
8010740d:	6a 40                	push   $0x40
8010740f:	e8 c3 ff ff ff       	call   801073d7 <outb>
80107414:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
80107417:	6a 04                	push   $0x4
80107419:	6a 40                	push   $0x40
8010741b:	e8 b7 ff ff ff       	call   801073d7 <outb>
80107420:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107423:	83 ec 0c             	sub    $0xc,%esp
80107426:	6a 00                	push   $0x0
80107428:	e8 b0 cb ff ff       	call   80103fdd <picenable>
8010742d:	83 c4 10             	add    $0x10,%esp
}
80107430:	90                   	nop
80107431:	c9                   	leave  
80107432:	c3                   	ret    

80107433 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107433:	1e                   	push   %ds
  pushl %es
80107434:	06                   	push   %es
  pushl %fs
80107435:	0f a0                	push   %fs
  pushl %gs
80107437:	0f a8                	push   %gs
  pushal
80107439:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010743a:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010743e:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107440:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107442:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107446:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107448:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010744a:	54                   	push   %esp
  call trap
8010744b:	e8 ce 01 00 00       	call   8010761e <trap>
  addl $4, %esp
80107450:	83 c4 04             	add    $0x4,%esp

80107453 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107453:	61                   	popa   
  popl %gs
80107454:	0f a9                	pop    %gs
  popl %fs
80107456:	0f a1                	pop    %fs
  popl %es
80107458:	07                   	pop    %es
  popl %ds
80107459:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010745a:	83 c4 08             	add    $0x8,%esp
  iret
8010745d:	cf                   	iret   

8010745e <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
8010745e:	55                   	push   %ebp
8010745f:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80107461:	8b 45 08             	mov    0x8(%ebp),%eax
80107464:	f0 ff 00             	lock incl (%eax)
}
80107467:	90                   	nop
80107468:	5d                   	pop    %ebp
80107469:	c3                   	ret    

8010746a <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010746a:	55                   	push   %ebp
8010746b:	89 e5                	mov    %esp,%ebp
8010746d:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107470:	8b 45 0c             	mov    0xc(%ebp),%eax
80107473:	83 e8 01             	sub    $0x1,%eax
80107476:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010747a:	8b 45 08             	mov    0x8(%ebp),%eax
8010747d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107481:	8b 45 08             	mov    0x8(%ebp),%eax
80107484:	c1 e8 10             	shr    $0x10,%eax
80107487:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010748b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010748e:	0f 01 18             	lidtl  (%eax)
}
80107491:	90                   	nop
80107492:	c9                   	leave  
80107493:	c3                   	ret    

80107494 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107494:	55                   	push   %ebp
80107495:	89 e5                	mov    %esp,%ebp
80107497:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010749a:	0f 20 d0             	mov    %cr2,%eax
8010749d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801074a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801074a3:	c9                   	leave  
801074a4:	c3                   	ret    

801074a5 <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
801074a5:	55                   	push   %ebp
801074a6:	89 e5                	mov    %esp,%ebp
801074a8:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
801074ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801074b2:	e9 c3 00 00 00       	jmp    8010757a <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801074b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074ba:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
801074c1:	89 c2                	mov    %eax,%edx
801074c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074c6:	66 89 14 c5 00 5f 11 	mov    %dx,-0x7feea100(,%eax,8)
801074cd:	80 
801074ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074d1:	66 c7 04 c5 02 5f 11 	movw   $0x8,-0x7feea0fe(,%eax,8)
801074d8:	80 08 00 
801074db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074de:	0f b6 14 c5 04 5f 11 	movzbl -0x7feea0fc(,%eax,8),%edx
801074e5:	80 
801074e6:	83 e2 e0             	and    $0xffffffe0,%edx
801074e9:	88 14 c5 04 5f 11 80 	mov    %dl,-0x7feea0fc(,%eax,8)
801074f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801074f3:	0f b6 14 c5 04 5f 11 	movzbl -0x7feea0fc(,%eax,8),%edx
801074fa:	80 
801074fb:	83 e2 1f             	and    $0x1f,%edx
801074fe:	88 14 c5 04 5f 11 80 	mov    %dl,-0x7feea0fc(,%eax,8)
80107505:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107508:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
8010750f:	80 
80107510:	83 e2 f0             	and    $0xfffffff0,%edx
80107513:	83 ca 0e             	or     $0xe,%edx
80107516:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
8010751d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107520:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
80107527:	80 
80107528:	83 e2 ef             	and    $0xffffffef,%edx
8010752b:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
80107532:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107535:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
8010753c:	80 
8010753d:	83 e2 9f             	and    $0xffffff9f,%edx
80107540:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
80107547:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010754a:	0f b6 14 c5 05 5f 11 	movzbl -0x7feea0fb(,%eax,8),%edx
80107551:	80 
80107552:	83 ca 80             	or     $0xffffff80,%edx
80107555:	88 14 c5 05 5f 11 80 	mov    %dl,-0x7feea0fb(,%eax,8)
8010755c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010755f:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
80107566:	c1 e8 10             	shr    $0x10,%eax
80107569:	89 c2                	mov    %eax,%edx
8010756b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010756e:	66 89 14 c5 06 5f 11 	mov    %dx,-0x7feea0fa(,%eax,8)
80107575:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107576:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010757a:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80107581:	0f 8e 30 ff ff ff    	jle    801074b7 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107587:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
8010758c:	66 a3 00 61 11 80    	mov    %ax,0x80116100
80107592:	66 c7 05 02 61 11 80 	movw   $0x8,0x80116102
80107599:	08 00 
8010759b:	0f b6 05 04 61 11 80 	movzbl 0x80116104,%eax
801075a2:	83 e0 e0             	and    $0xffffffe0,%eax
801075a5:	a2 04 61 11 80       	mov    %al,0x80116104
801075aa:	0f b6 05 04 61 11 80 	movzbl 0x80116104,%eax
801075b1:	83 e0 1f             	and    $0x1f,%eax
801075b4:	a2 04 61 11 80       	mov    %al,0x80116104
801075b9:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801075c0:	83 c8 0f             	or     $0xf,%eax
801075c3:	a2 05 61 11 80       	mov    %al,0x80116105
801075c8:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801075cf:	83 e0 ef             	and    $0xffffffef,%eax
801075d2:	a2 05 61 11 80       	mov    %al,0x80116105
801075d7:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801075de:	83 c8 60             	or     $0x60,%eax
801075e1:	a2 05 61 11 80       	mov    %al,0x80116105
801075e6:	0f b6 05 05 61 11 80 	movzbl 0x80116105,%eax
801075ed:	83 c8 80             	or     $0xffffff80,%eax
801075f0:	a2 05 61 11 80       	mov    %al,0x80116105
801075f5:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
801075fa:	c1 e8 10             	shr    $0x10,%eax
801075fd:	66 a3 06 61 11 80    	mov    %ax,0x80116106
  
}
80107603:	90                   	nop
80107604:	c9                   	leave  
80107605:	c3                   	ret    

80107606 <idtinit>:

void
idtinit(void)
{
80107606:	55                   	push   %ebp
80107607:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80107609:	68 00 08 00 00       	push   $0x800
8010760e:	68 00 5f 11 80       	push   $0x80115f00
80107613:	e8 52 fe ff ff       	call   8010746a <lidt>
80107618:	83 c4 08             	add    $0x8,%esp
}
8010761b:	90                   	nop
8010761c:	c9                   	leave  
8010761d:	c3                   	ret    

8010761e <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010761e:	55                   	push   %ebp
8010761f:	89 e5                	mov    %esp,%ebp
80107621:	57                   	push   %edi
80107622:	56                   	push   %esi
80107623:	53                   	push   %ebx
80107624:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80107627:	8b 45 08             	mov    0x8(%ebp),%eax
8010762a:	8b 40 30             	mov    0x30(%eax),%eax
8010762d:	83 f8 40             	cmp    $0x40,%eax
80107630:	75 3e                	jne    80107670 <trap+0x52>
    if(proc->killed)
80107632:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107638:	8b 40 24             	mov    0x24(%eax),%eax
8010763b:	85 c0                	test   %eax,%eax
8010763d:	74 05                	je     80107644 <trap+0x26>
      exit();
8010763f:	e8 16 d4 ff ff       	call   80104a5a <exit>
    proc->tf = tf;
80107644:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010764a:	8b 55 08             	mov    0x8(%ebp),%edx
8010764d:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107650:	e8 9d ec ff ff       	call   801062f2 <syscall>
    if(proc->killed)
80107655:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010765b:	8b 40 24             	mov    0x24(%eax),%eax
8010765e:	85 c0                	test   %eax,%eax
80107660:	0f 84 21 02 00 00    	je     80107887 <trap+0x269>
      exit();
80107666:	e8 ef d3 ff ff       	call   80104a5a <exit>
    return;
8010766b:	e9 17 02 00 00       	jmp    80107887 <trap+0x269>
  }

  switch(tf->trapno){
80107670:	8b 45 08             	mov    0x8(%ebp),%eax
80107673:	8b 40 30             	mov    0x30(%eax),%eax
80107676:	83 e8 20             	sub    $0x20,%eax
80107679:	83 f8 1f             	cmp    $0x1f,%eax
8010767c:	0f 87 a3 00 00 00    	ja     80107725 <trap+0x107>
80107682:	8b 04 85 50 9b 10 80 	mov    -0x7fef64b0(,%eax,4),%eax
80107689:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
8010768b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107691:	0f b6 00             	movzbl (%eax),%eax
80107694:	84 c0                	test   %al,%al
80107696:	75 20                	jne    801076b8 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
80107698:	83 ec 0c             	sub    $0xc,%esp
8010769b:	68 00 67 11 80       	push   $0x80116700
801076a0:	e8 b9 fd ff ff       	call   8010745e <atom_inc>
801076a5:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
801076a8:	83 ec 0c             	sub    $0xc,%esp
801076ab:	68 00 67 11 80       	push   $0x80116700
801076b0:	e8 69 d9 ff ff       	call   8010501e <wakeup>
801076b5:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801076b8:	e8 1a ba ff ff       	call   801030d7 <lapiceoi>
    break;
801076bd:	e9 1c 01 00 00       	jmp    801077de <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801076c2:	e8 23 b2 ff ff       	call   801028ea <ideintr>
    lapiceoi();
801076c7:	e8 0b ba ff ff       	call   801030d7 <lapiceoi>
    break;
801076cc:	e9 0d 01 00 00       	jmp    801077de <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801076d1:	e8 03 b8 ff ff       	call   80102ed9 <kbdintr>
    lapiceoi();
801076d6:	e8 fc b9 ff ff       	call   801030d7 <lapiceoi>
    break;
801076db:	e9 fe 00 00 00       	jmp    801077de <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801076e0:	e8 83 03 00 00       	call   80107a68 <uartintr>
    lapiceoi();
801076e5:	e8 ed b9 ff ff       	call   801030d7 <lapiceoi>
    break;
801076ea:	e9 ef 00 00 00       	jmp    801077de <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801076ef:	8b 45 08             	mov    0x8(%ebp),%eax
801076f2:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801076f5:	8b 45 08             	mov    0x8(%ebp),%eax
801076f8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801076fc:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801076ff:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107705:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107708:	0f b6 c0             	movzbl %al,%eax
8010770b:	51                   	push   %ecx
8010770c:	52                   	push   %edx
8010770d:	50                   	push   %eax
8010770e:	68 b0 9a 10 80       	push   $0x80109ab0
80107713:	e8 ae 8c ff ff       	call   801003c6 <cprintf>
80107718:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
8010771b:	e8 b7 b9 ff ff       	call   801030d7 <lapiceoi>
    break;
80107720:	e9 b9 00 00 00       	jmp    801077de <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107725:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010772b:	85 c0                	test   %eax,%eax
8010772d:	74 11                	je     80107740 <trap+0x122>
8010772f:	8b 45 08             	mov    0x8(%ebp),%eax
80107732:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107736:	0f b7 c0             	movzwl %ax,%eax
80107739:	83 e0 03             	and    $0x3,%eax
8010773c:	85 c0                	test   %eax,%eax
8010773e:	75 40                	jne    80107780 <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107740:	e8 4f fd ff ff       	call   80107494 <rcr2>
80107745:	89 c3                	mov    %eax,%ebx
80107747:	8b 45 08             	mov    0x8(%ebp),%eax
8010774a:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010774d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107753:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107756:	0f b6 d0             	movzbl %al,%edx
80107759:	8b 45 08             	mov    0x8(%ebp),%eax
8010775c:	8b 40 30             	mov    0x30(%eax),%eax
8010775f:	83 ec 0c             	sub    $0xc,%esp
80107762:	53                   	push   %ebx
80107763:	51                   	push   %ecx
80107764:	52                   	push   %edx
80107765:	50                   	push   %eax
80107766:	68 d4 9a 10 80       	push   $0x80109ad4
8010776b:	e8 56 8c ff ff       	call   801003c6 <cprintf>
80107770:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107773:	83 ec 0c             	sub    $0xc,%esp
80107776:	68 06 9b 10 80       	push   $0x80109b06
8010777b:	e8 e6 8d ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107780:	e8 0f fd ff ff       	call   80107494 <rcr2>
80107785:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107788:	8b 45 08             	mov    0x8(%ebp),%eax
8010778b:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
8010778e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107794:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107797:	0f b6 d8             	movzbl %al,%ebx
8010779a:	8b 45 08             	mov    0x8(%ebp),%eax
8010779d:	8b 48 34             	mov    0x34(%eax),%ecx
801077a0:	8b 45 08             	mov    0x8(%ebp),%eax
801077a3:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801077a6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077ac:	8d 78 6c             	lea    0x6c(%eax),%edi
801077af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801077b5:	8b 40 10             	mov    0x10(%eax),%eax
801077b8:	ff 75 e4             	pushl  -0x1c(%ebp)
801077bb:	56                   	push   %esi
801077bc:	53                   	push   %ebx
801077bd:	51                   	push   %ecx
801077be:	52                   	push   %edx
801077bf:	57                   	push   %edi
801077c0:	50                   	push   %eax
801077c1:	68 0c 9b 10 80       	push   $0x80109b0c
801077c6:	e8 fb 8b ff ff       	call   801003c6 <cprintf>
801077cb:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
801077ce:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077d4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801077db:	eb 01                	jmp    801077de <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801077dd:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801077de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077e4:	85 c0                	test   %eax,%eax
801077e6:	74 24                	je     8010780c <trap+0x1ee>
801077e8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801077ee:	8b 40 24             	mov    0x24(%eax),%eax
801077f1:	85 c0                	test   %eax,%eax
801077f3:	74 17                	je     8010780c <trap+0x1ee>
801077f5:	8b 45 08             	mov    0x8(%ebp),%eax
801077f8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801077fc:	0f b7 c0             	movzwl %ax,%eax
801077ff:	83 e0 03             	and    $0x3,%eax
80107802:	83 f8 03             	cmp    $0x3,%eax
80107805:	75 05                	jne    8010780c <trap+0x1ee>
    exit();
80107807:	e8 4e d2 ff ff       	call   80104a5a <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010780c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107812:	85 c0                	test   %eax,%eax
80107814:	74 41                	je     80107857 <trap+0x239>
80107816:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010781c:	8b 40 0c             	mov    0xc(%eax),%eax
8010781f:	83 f8 04             	cmp    $0x4,%eax
80107822:	75 33                	jne    80107857 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80107824:	8b 45 08             	mov    0x8(%ebp),%eax
80107827:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
8010782a:	83 f8 20             	cmp    $0x20,%eax
8010782d:	75 28                	jne    80107857 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
8010782f:	8b 0d 00 67 11 80    	mov    0x80116700,%ecx
80107835:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
8010783a:	89 c8                	mov    %ecx,%eax
8010783c:	f7 e2                	mul    %edx
8010783e:	c1 ea 03             	shr    $0x3,%edx
80107841:	89 d0                	mov    %edx,%eax
80107843:	c1 e0 02             	shl    $0x2,%eax
80107846:	01 d0                	add    %edx,%eax
80107848:	01 c0                	add    %eax,%eax
8010784a:	29 c1                	sub    %eax,%ecx
8010784c:	89 ca                	mov    %ecx,%edx
8010784e:	85 d2                	test   %edx,%edx
80107850:	75 05                	jne    80107857 <trap+0x239>
    yield();
80107852:	e8 28 d6 ff ff       	call   80104e7f <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107857:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010785d:	85 c0                	test   %eax,%eax
8010785f:	74 27                	je     80107888 <trap+0x26a>
80107861:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107867:	8b 40 24             	mov    0x24(%eax),%eax
8010786a:	85 c0                	test   %eax,%eax
8010786c:	74 1a                	je     80107888 <trap+0x26a>
8010786e:	8b 45 08             	mov    0x8(%ebp),%eax
80107871:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107875:	0f b7 c0             	movzwl %ax,%eax
80107878:	83 e0 03             	and    $0x3,%eax
8010787b:	83 f8 03             	cmp    $0x3,%eax
8010787e:	75 08                	jne    80107888 <trap+0x26a>
    exit();
80107880:	e8 d5 d1 ff ff       	call   80104a5a <exit>
80107885:	eb 01                	jmp    80107888 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107887:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80107888:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010788b:	5b                   	pop    %ebx
8010788c:	5e                   	pop    %esi
8010788d:	5f                   	pop    %edi
8010788e:	5d                   	pop    %ebp
8010788f:	c3                   	ret    

80107890 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80107890:	55                   	push   %ebp
80107891:	89 e5                	mov    %esp,%ebp
80107893:	83 ec 14             	sub    $0x14,%esp
80107896:	8b 45 08             	mov    0x8(%ebp),%eax
80107899:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010789d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801078a1:	89 c2                	mov    %eax,%edx
801078a3:	ec                   	in     (%dx),%al
801078a4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801078a7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801078ab:	c9                   	leave  
801078ac:	c3                   	ret    

801078ad <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801078ad:	55                   	push   %ebp
801078ae:	89 e5                	mov    %esp,%ebp
801078b0:	83 ec 08             	sub    $0x8,%esp
801078b3:	8b 55 08             	mov    0x8(%ebp),%edx
801078b6:	8b 45 0c             	mov    0xc(%ebp),%eax
801078b9:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801078bd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801078c0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801078c4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801078c8:	ee                   	out    %al,(%dx)
}
801078c9:	90                   	nop
801078ca:	c9                   	leave  
801078cb:	c3                   	ret    

801078cc <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801078cc:	55                   	push   %ebp
801078cd:	89 e5                	mov    %esp,%ebp
801078cf:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801078d2:	6a 00                	push   $0x0
801078d4:	68 fa 03 00 00       	push   $0x3fa
801078d9:	e8 cf ff ff ff       	call   801078ad <outb>
801078de:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801078e1:	68 80 00 00 00       	push   $0x80
801078e6:	68 fb 03 00 00       	push   $0x3fb
801078eb:	e8 bd ff ff ff       	call   801078ad <outb>
801078f0:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
801078f3:	6a 0c                	push   $0xc
801078f5:	68 f8 03 00 00       	push   $0x3f8
801078fa:	e8 ae ff ff ff       	call   801078ad <outb>
801078ff:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107902:	6a 00                	push   $0x0
80107904:	68 f9 03 00 00       	push   $0x3f9
80107909:	e8 9f ff ff ff       	call   801078ad <outb>
8010790e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107911:	6a 03                	push   $0x3
80107913:	68 fb 03 00 00       	push   $0x3fb
80107918:	e8 90 ff ff ff       	call   801078ad <outb>
8010791d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107920:	6a 00                	push   $0x0
80107922:	68 fc 03 00 00       	push   $0x3fc
80107927:	e8 81 ff ff ff       	call   801078ad <outb>
8010792c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010792f:	6a 01                	push   $0x1
80107931:	68 f9 03 00 00       	push   $0x3f9
80107936:	e8 72 ff ff ff       	call   801078ad <outb>
8010793b:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010793e:	68 fd 03 00 00       	push   $0x3fd
80107943:	e8 48 ff ff ff       	call   80107890 <inb>
80107948:	83 c4 04             	add    $0x4,%esp
8010794b:	3c ff                	cmp    $0xff,%al
8010794d:	74 6e                	je     801079bd <uartinit+0xf1>
    return;
  uart = 1;
8010794f:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107956:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107959:	68 fa 03 00 00       	push   $0x3fa
8010795e:	e8 2d ff ff ff       	call   80107890 <inb>
80107963:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107966:	68 f8 03 00 00       	push   $0x3f8
8010796b:	e8 20 ff ff ff       	call   80107890 <inb>
80107970:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107973:	83 ec 0c             	sub    $0xc,%esp
80107976:	6a 04                	push   $0x4
80107978:	e8 60 c6 ff ff       	call   80103fdd <picenable>
8010797d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107980:	83 ec 08             	sub    $0x8,%esp
80107983:	6a 00                	push   $0x0
80107985:	6a 04                	push   $0x4
80107987:	e8 00 b2 ff ff       	call   80102b8c <ioapicenable>
8010798c:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010798f:	c7 45 f4 d0 9b 10 80 	movl   $0x80109bd0,-0xc(%ebp)
80107996:	eb 19                	jmp    801079b1 <uartinit+0xe5>
    uartputc(*p);
80107998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010799b:	0f b6 00             	movzbl (%eax),%eax
8010799e:	0f be c0             	movsbl %al,%eax
801079a1:	83 ec 0c             	sub    $0xc,%esp
801079a4:	50                   	push   %eax
801079a5:	e8 16 00 00 00       	call   801079c0 <uartputc>
801079aa:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801079ad:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801079b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b4:	0f b6 00             	movzbl (%eax),%eax
801079b7:	84 c0                	test   %al,%al
801079b9:	75 dd                	jne    80107998 <uartinit+0xcc>
801079bb:	eb 01                	jmp    801079be <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801079bd:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801079be:	c9                   	leave  
801079bf:	c3                   	ret    

801079c0 <uartputc>:

void
uartputc(int c)
{
801079c0:	55                   	push   %ebp
801079c1:	89 e5                	mov    %esp,%ebp
801079c3:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801079c6:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801079cb:	85 c0                	test   %eax,%eax
801079cd:	74 53                	je     80107a22 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801079cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079d6:	eb 11                	jmp    801079e9 <uartputc+0x29>
    microdelay(10);
801079d8:	83 ec 0c             	sub    $0xc,%esp
801079db:	6a 0a                	push   $0xa
801079dd:	e8 10 b7 ff ff       	call   801030f2 <microdelay>
801079e2:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801079e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801079e9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801079ed:	7f 1a                	jg     80107a09 <uartputc+0x49>
801079ef:	83 ec 0c             	sub    $0xc,%esp
801079f2:	68 fd 03 00 00       	push   $0x3fd
801079f7:	e8 94 fe ff ff       	call   80107890 <inb>
801079fc:	83 c4 10             	add    $0x10,%esp
801079ff:	0f b6 c0             	movzbl %al,%eax
80107a02:	83 e0 20             	and    $0x20,%eax
80107a05:	85 c0                	test   %eax,%eax
80107a07:	74 cf                	je     801079d8 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80107a09:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0c:	0f b6 c0             	movzbl %al,%eax
80107a0f:	83 ec 08             	sub    $0x8,%esp
80107a12:	50                   	push   %eax
80107a13:	68 f8 03 00 00       	push   $0x3f8
80107a18:	e8 90 fe ff ff       	call   801078ad <outb>
80107a1d:	83 c4 10             	add    $0x10,%esp
80107a20:	eb 01                	jmp    80107a23 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107a22:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107a23:	c9                   	leave  
80107a24:	c3                   	ret    

80107a25 <uartgetc>:

static int
uartgetc(void)
{
80107a25:	55                   	push   %ebp
80107a26:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107a28:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107a2d:	85 c0                	test   %eax,%eax
80107a2f:	75 07                	jne    80107a38 <uartgetc+0x13>
    return -1;
80107a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a36:	eb 2e                	jmp    80107a66 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107a38:	68 fd 03 00 00       	push   $0x3fd
80107a3d:	e8 4e fe ff ff       	call   80107890 <inb>
80107a42:	83 c4 04             	add    $0x4,%esp
80107a45:	0f b6 c0             	movzbl %al,%eax
80107a48:	83 e0 01             	and    $0x1,%eax
80107a4b:	85 c0                	test   %eax,%eax
80107a4d:	75 07                	jne    80107a56 <uartgetc+0x31>
    return -1;
80107a4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a54:	eb 10                	jmp    80107a66 <uartgetc+0x41>
  return inb(COM1+0);
80107a56:	68 f8 03 00 00       	push   $0x3f8
80107a5b:	e8 30 fe ff ff       	call   80107890 <inb>
80107a60:	83 c4 04             	add    $0x4,%esp
80107a63:	0f b6 c0             	movzbl %al,%eax
}
80107a66:	c9                   	leave  
80107a67:	c3                   	ret    

80107a68 <uartintr>:

void
uartintr(void)
{
80107a68:	55                   	push   %ebp
80107a69:	89 e5                	mov    %esp,%ebp
80107a6b:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107a6e:	83 ec 0c             	sub    $0xc,%esp
80107a71:	68 25 7a 10 80       	push   $0x80107a25
80107a76:	e8 7e 8d ff ff       	call   801007f9 <consoleintr>
80107a7b:	83 c4 10             	add    $0x10,%esp
}
80107a7e:	90                   	nop
80107a7f:	c9                   	leave  
80107a80:	c3                   	ret    

80107a81 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $0
80107a83:	6a 00                	push   $0x0
  jmp alltraps
80107a85:	e9 a9 f9 ff ff       	jmp    80107433 <alltraps>

80107a8a <vector1>:
.globl vector1
vector1:
  pushl $0
80107a8a:	6a 00                	push   $0x0
  pushl $1
80107a8c:	6a 01                	push   $0x1
  jmp alltraps
80107a8e:	e9 a0 f9 ff ff       	jmp    80107433 <alltraps>

80107a93 <vector2>:
.globl vector2
vector2:
  pushl $0
80107a93:	6a 00                	push   $0x0
  pushl $2
80107a95:	6a 02                	push   $0x2
  jmp alltraps
80107a97:	e9 97 f9 ff ff       	jmp    80107433 <alltraps>

80107a9c <vector3>:
.globl vector3
vector3:
  pushl $0
80107a9c:	6a 00                	push   $0x0
  pushl $3
80107a9e:	6a 03                	push   $0x3
  jmp alltraps
80107aa0:	e9 8e f9 ff ff       	jmp    80107433 <alltraps>

80107aa5 <vector4>:
.globl vector4
vector4:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $4
80107aa7:	6a 04                	push   $0x4
  jmp alltraps
80107aa9:	e9 85 f9 ff ff       	jmp    80107433 <alltraps>

80107aae <vector5>:
.globl vector5
vector5:
  pushl $0
80107aae:	6a 00                	push   $0x0
  pushl $5
80107ab0:	6a 05                	push   $0x5
  jmp alltraps
80107ab2:	e9 7c f9 ff ff       	jmp    80107433 <alltraps>

80107ab7 <vector6>:
.globl vector6
vector6:
  pushl $0
80107ab7:	6a 00                	push   $0x0
  pushl $6
80107ab9:	6a 06                	push   $0x6
  jmp alltraps
80107abb:	e9 73 f9 ff ff       	jmp    80107433 <alltraps>

80107ac0 <vector7>:
.globl vector7
vector7:
  pushl $0
80107ac0:	6a 00                	push   $0x0
  pushl $7
80107ac2:	6a 07                	push   $0x7
  jmp alltraps
80107ac4:	e9 6a f9 ff ff       	jmp    80107433 <alltraps>

80107ac9 <vector8>:
.globl vector8
vector8:
  pushl $8
80107ac9:	6a 08                	push   $0x8
  jmp alltraps
80107acb:	e9 63 f9 ff ff       	jmp    80107433 <alltraps>

80107ad0 <vector9>:
.globl vector9
vector9:
  pushl $0
80107ad0:	6a 00                	push   $0x0
  pushl $9
80107ad2:	6a 09                	push   $0x9
  jmp alltraps
80107ad4:	e9 5a f9 ff ff       	jmp    80107433 <alltraps>

80107ad9 <vector10>:
.globl vector10
vector10:
  pushl $10
80107ad9:	6a 0a                	push   $0xa
  jmp alltraps
80107adb:	e9 53 f9 ff ff       	jmp    80107433 <alltraps>

80107ae0 <vector11>:
.globl vector11
vector11:
  pushl $11
80107ae0:	6a 0b                	push   $0xb
  jmp alltraps
80107ae2:	e9 4c f9 ff ff       	jmp    80107433 <alltraps>

80107ae7 <vector12>:
.globl vector12
vector12:
  pushl $12
80107ae7:	6a 0c                	push   $0xc
  jmp alltraps
80107ae9:	e9 45 f9 ff ff       	jmp    80107433 <alltraps>

80107aee <vector13>:
.globl vector13
vector13:
  pushl $13
80107aee:	6a 0d                	push   $0xd
  jmp alltraps
80107af0:	e9 3e f9 ff ff       	jmp    80107433 <alltraps>

80107af5 <vector14>:
.globl vector14
vector14:
  pushl $14
80107af5:	6a 0e                	push   $0xe
  jmp alltraps
80107af7:	e9 37 f9 ff ff       	jmp    80107433 <alltraps>

80107afc <vector15>:
.globl vector15
vector15:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $15
80107afe:	6a 0f                	push   $0xf
  jmp alltraps
80107b00:	e9 2e f9 ff ff       	jmp    80107433 <alltraps>

80107b05 <vector16>:
.globl vector16
vector16:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $16
80107b07:	6a 10                	push   $0x10
  jmp alltraps
80107b09:	e9 25 f9 ff ff       	jmp    80107433 <alltraps>

80107b0e <vector17>:
.globl vector17
vector17:
  pushl $17
80107b0e:	6a 11                	push   $0x11
  jmp alltraps
80107b10:	e9 1e f9 ff ff       	jmp    80107433 <alltraps>

80107b15 <vector18>:
.globl vector18
vector18:
  pushl $0
80107b15:	6a 00                	push   $0x0
  pushl $18
80107b17:	6a 12                	push   $0x12
  jmp alltraps
80107b19:	e9 15 f9 ff ff       	jmp    80107433 <alltraps>

80107b1e <vector19>:
.globl vector19
vector19:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $19
80107b20:	6a 13                	push   $0x13
  jmp alltraps
80107b22:	e9 0c f9 ff ff       	jmp    80107433 <alltraps>

80107b27 <vector20>:
.globl vector20
vector20:
  pushl $0
80107b27:	6a 00                	push   $0x0
  pushl $20
80107b29:	6a 14                	push   $0x14
  jmp alltraps
80107b2b:	e9 03 f9 ff ff       	jmp    80107433 <alltraps>

80107b30 <vector21>:
.globl vector21
vector21:
  pushl $0
80107b30:	6a 00                	push   $0x0
  pushl $21
80107b32:	6a 15                	push   $0x15
  jmp alltraps
80107b34:	e9 fa f8 ff ff       	jmp    80107433 <alltraps>

80107b39 <vector22>:
.globl vector22
vector22:
  pushl $0
80107b39:	6a 00                	push   $0x0
  pushl $22
80107b3b:	6a 16                	push   $0x16
  jmp alltraps
80107b3d:	e9 f1 f8 ff ff       	jmp    80107433 <alltraps>

80107b42 <vector23>:
.globl vector23
vector23:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $23
80107b44:	6a 17                	push   $0x17
  jmp alltraps
80107b46:	e9 e8 f8 ff ff       	jmp    80107433 <alltraps>

80107b4b <vector24>:
.globl vector24
vector24:
  pushl $0
80107b4b:	6a 00                	push   $0x0
  pushl $24
80107b4d:	6a 18                	push   $0x18
  jmp alltraps
80107b4f:	e9 df f8 ff ff       	jmp    80107433 <alltraps>

80107b54 <vector25>:
.globl vector25
vector25:
  pushl $0
80107b54:	6a 00                	push   $0x0
  pushl $25
80107b56:	6a 19                	push   $0x19
  jmp alltraps
80107b58:	e9 d6 f8 ff ff       	jmp    80107433 <alltraps>

80107b5d <vector26>:
.globl vector26
vector26:
  pushl $0
80107b5d:	6a 00                	push   $0x0
  pushl $26
80107b5f:	6a 1a                	push   $0x1a
  jmp alltraps
80107b61:	e9 cd f8 ff ff       	jmp    80107433 <alltraps>

80107b66 <vector27>:
.globl vector27
vector27:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $27
80107b68:	6a 1b                	push   $0x1b
  jmp alltraps
80107b6a:	e9 c4 f8 ff ff       	jmp    80107433 <alltraps>

80107b6f <vector28>:
.globl vector28
vector28:
  pushl $0
80107b6f:	6a 00                	push   $0x0
  pushl $28
80107b71:	6a 1c                	push   $0x1c
  jmp alltraps
80107b73:	e9 bb f8 ff ff       	jmp    80107433 <alltraps>

80107b78 <vector29>:
.globl vector29
vector29:
  pushl $0
80107b78:	6a 00                	push   $0x0
  pushl $29
80107b7a:	6a 1d                	push   $0x1d
  jmp alltraps
80107b7c:	e9 b2 f8 ff ff       	jmp    80107433 <alltraps>

80107b81 <vector30>:
.globl vector30
vector30:
  pushl $0
80107b81:	6a 00                	push   $0x0
  pushl $30
80107b83:	6a 1e                	push   $0x1e
  jmp alltraps
80107b85:	e9 a9 f8 ff ff       	jmp    80107433 <alltraps>

80107b8a <vector31>:
.globl vector31
vector31:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $31
80107b8c:	6a 1f                	push   $0x1f
  jmp alltraps
80107b8e:	e9 a0 f8 ff ff       	jmp    80107433 <alltraps>

80107b93 <vector32>:
.globl vector32
vector32:
  pushl $0
80107b93:	6a 00                	push   $0x0
  pushl $32
80107b95:	6a 20                	push   $0x20
  jmp alltraps
80107b97:	e9 97 f8 ff ff       	jmp    80107433 <alltraps>

80107b9c <vector33>:
.globl vector33
vector33:
  pushl $0
80107b9c:	6a 00                	push   $0x0
  pushl $33
80107b9e:	6a 21                	push   $0x21
  jmp alltraps
80107ba0:	e9 8e f8 ff ff       	jmp    80107433 <alltraps>

80107ba5 <vector34>:
.globl vector34
vector34:
  pushl $0
80107ba5:	6a 00                	push   $0x0
  pushl $34
80107ba7:	6a 22                	push   $0x22
  jmp alltraps
80107ba9:	e9 85 f8 ff ff       	jmp    80107433 <alltraps>

80107bae <vector35>:
.globl vector35
vector35:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $35
80107bb0:	6a 23                	push   $0x23
  jmp alltraps
80107bb2:	e9 7c f8 ff ff       	jmp    80107433 <alltraps>

80107bb7 <vector36>:
.globl vector36
vector36:
  pushl $0
80107bb7:	6a 00                	push   $0x0
  pushl $36
80107bb9:	6a 24                	push   $0x24
  jmp alltraps
80107bbb:	e9 73 f8 ff ff       	jmp    80107433 <alltraps>

80107bc0 <vector37>:
.globl vector37
vector37:
  pushl $0
80107bc0:	6a 00                	push   $0x0
  pushl $37
80107bc2:	6a 25                	push   $0x25
  jmp alltraps
80107bc4:	e9 6a f8 ff ff       	jmp    80107433 <alltraps>

80107bc9 <vector38>:
.globl vector38
vector38:
  pushl $0
80107bc9:	6a 00                	push   $0x0
  pushl $38
80107bcb:	6a 26                	push   $0x26
  jmp alltraps
80107bcd:	e9 61 f8 ff ff       	jmp    80107433 <alltraps>

80107bd2 <vector39>:
.globl vector39
vector39:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $39
80107bd4:	6a 27                	push   $0x27
  jmp alltraps
80107bd6:	e9 58 f8 ff ff       	jmp    80107433 <alltraps>

80107bdb <vector40>:
.globl vector40
vector40:
  pushl $0
80107bdb:	6a 00                	push   $0x0
  pushl $40
80107bdd:	6a 28                	push   $0x28
  jmp alltraps
80107bdf:	e9 4f f8 ff ff       	jmp    80107433 <alltraps>

80107be4 <vector41>:
.globl vector41
vector41:
  pushl $0
80107be4:	6a 00                	push   $0x0
  pushl $41
80107be6:	6a 29                	push   $0x29
  jmp alltraps
80107be8:	e9 46 f8 ff ff       	jmp    80107433 <alltraps>

80107bed <vector42>:
.globl vector42
vector42:
  pushl $0
80107bed:	6a 00                	push   $0x0
  pushl $42
80107bef:	6a 2a                	push   $0x2a
  jmp alltraps
80107bf1:	e9 3d f8 ff ff       	jmp    80107433 <alltraps>

80107bf6 <vector43>:
.globl vector43
vector43:
  pushl $0
80107bf6:	6a 00                	push   $0x0
  pushl $43
80107bf8:	6a 2b                	push   $0x2b
  jmp alltraps
80107bfa:	e9 34 f8 ff ff       	jmp    80107433 <alltraps>

80107bff <vector44>:
.globl vector44
vector44:
  pushl $0
80107bff:	6a 00                	push   $0x0
  pushl $44
80107c01:	6a 2c                	push   $0x2c
  jmp alltraps
80107c03:	e9 2b f8 ff ff       	jmp    80107433 <alltraps>

80107c08 <vector45>:
.globl vector45
vector45:
  pushl $0
80107c08:	6a 00                	push   $0x0
  pushl $45
80107c0a:	6a 2d                	push   $0x2d
  jmp alltraps
80107c0c:	e9 22 f8 ff ff       	jmp    80107433 <alltraps>

80107c11 <vector46>:
.globl vector46
vector46:
  pushl $0
80107c11:	6a 00                	push   $0x0
  pushl $46
80107c13:	6a 2e                	push   $0x2e
  jmp alltraps
80107c15:	e9 19 f8 ff ff       	jmp    80107433 <alltraps>

80107c1a <vector47>:
.globl vector47
vector47:
  pushl $0
80107c1a:	6a 00                	push   $0x0
  pushl $47
80107c1c:	6a 2f                	push   $0x2f
  jmp alltraps
80107c1e:	e9 10 f8 ff ff       	jmp    80107433 <alltraps>

80107c23 <vector48>:
.globl vector48
vector48:
  pushl $0
80107c23:	6a 00                	push   $0x0
  pushl $48
80107c25:	6a 30                	push   $0x30
  jmp alltraps
80107c27:	e9 07 f8 ff ff       	jmp    80107433 <alltraps>

80107c2c <vector49>:
.globl vector49
vector49:
  pushl $0
80107c2c:	6a 00                	push   $0x0
  pushl $49
80107c2e:	6a 31                	push   $0x31
  jmp alltraps
80107c30:	e9 fe f7 ff ff       	jmp    80107433 <alltraps>

80107c35 <vector50>:
.globl vector50
vector50:
  pushl $0
80107c35:	6a 00                	push   $0x0
  pushl $50
80107c37:	6a 32                	push   $0x32
  jmp alltraps
80107c39:	e9 f5 f7 ff ff       	jmp    80107433 <alltraps>

80107c3e <vector51>:
.globl vector51
vector51:
  pushl $0
80107c3e:	6a 00                	push   $0x0
  pushl $51
80107c40:	6a 33                	push   $0x33
  jmp alltraps
80107c42:	e9 ec f7 ff ff       	jmp    80107433 <alltraps>

80107c47 <vector52>:
.globl vector52
vector52:
  pushl $0
80107c47:	6a 00                	push   $0x0
  pushl $52
80107c49:	6a 34                	push   $0x34
  jmp alltraps
80107c4b:	e9 e3 f7 ff ff       	jmp    80107433 <alltraps>

80107c50 <vector53>:
.globl vector53
vector53:
  pushl $0
80107c50:	6a 00                	push   $0x0
  pushl $53
80107c52:	6a 35                	push   $0x35
  jmp alltraps
80107c54:	e9 da f7 ff ff       	jmp    80107433 <alltraps>

80107c59 <vector54>:
.globl vector54
vector54:
  pushl $0
80107c59:	6a 00                	push   $0x0
  pushl $54
80107c5b:	6a 36                	push   $0x36
  jmp alltraps
80107c5d:	e9 d1 f7 ff ff       	jmp    80107433 <alltraps>

80107c62 <vector55>:
.globl vector55
vector55:
  pushl $0
80107c62:	6a 00                	push   $0x0
  pushl $55
80107c64:	6a 37                	push   $0x37
  jmp alltraps
80107c66:	e9 c8 f7 ff ff       	jmp    80107433 <alltraps>

80107c6b <vector56>:
.globl vector56
vector56:
  pushl $0
80107c6b:	6a 00                	push   $0x0
  pushl $56
80107c6d:	6a 38                	push   $0x38
  jmp alltraps
80107c6f:	e9 bf f7 ff ff       	jmp    80107433 <alltraps>

80107c74 <vector57>:
.globl vector57
vector57:
  pushl $0
80107c74:	6a 00                	push   $0x0
  pushl $57
80107c76:	6a 39                	push   $0x39
  jmp alltraps
80107c78:	e9 b6 f7 ff ff       	jmp    80107433 <alltraps>

80107c7d <vector58>:
.globl vector58
vector58:
  pushl $0
80107c7d:	6a 00                	push   $0x0
  pushl $58
80107c7f:	6a 3a                	push   $0x3a
  jmp alltraps
80107c81:	e9 ad f7 ff ff       	jmp    80107433 <alltraps>

80107c86 <vector59>:
.globl vector59
vector59:
  pushl $0
80107c86:	6a 00                	push   $0x0
  pushl $59
80107c88:	6a 3b                	push   $0x3b
  jmp alltraps
80107c8a:	e9 a4 f7 ff ff       	jmp    80107433 <alltraps>

80107c8f <vector60>:
.globl vector60
vector60:
  pushl $0
80107c8f:	6a 00                	push   $0x0
  pushl $60
80107c91:	6a 3c                	push   $0x3c
  jmp alltraps
80107c93:	e9 9b f7 ff ff       	jmp    80107433 <alltraps>

80107c98 <vector61>:
.globl vector61
vector61:
  pushl $0
80107c98:	6a 00                	push   $0x0
  pushl $61
80107c9a:	6a 3d                	push   $0x3d
  jmp alltraps
80107c9c:	e9 92 f7 ff ff       	jmp    80107433 <alltraps>

80107ca1 <vector62>:
.globl vector62
vector62:
  pushl $0
80107ca1:	6a 00                	push   $0x0
  pushl $62
80107ca3:	6a 3e                	push   $0x3e
  jmp alltraps
80107ca5:	e9 89 f7 ff ff       	jmp    80107433 <alltraps>

80107caa <vector63>:
.globl vector63
vector63:
  pushl $0
80107caa:	6a 00                	push   $0x0
  pushl $63
80107cac:	6a 3f                	push   $0x3f
  jmp alltraps
80107cae:	e9 80 f7 ff ff       	jmp    80107433 <alltraps>

80107cb3 <vector64>:
.globl vector64
vector64:
  pushl $0
80107cb3:	6a 00                	push   $0x0
  pushl $64
80107cb5:	6a 40                	push   $0x40
  jmp alltraps
80107cb7:	e9 77 f7 ff ff       	jmp    80107433 <alltraps>

80107cbc <vector65>:
.globl vector65
vector65:
  pushl $0
80107cbc:	6a 00                	push   $0x0
  pushl $65
80107cbe:	6a 41                	push   $0x41
  jmp alltraps
80107cc0:	e9 6e f7 ff ff       	jmp    80107433 <alltraps>

80107cc5 <vector66>:
.globl vector66
vector66:
  pushl $0
80107cc5:	6a 00                	push   $0x0
  pushl $66
80107cc7:	6a 42                	push   $0x42
  jmp alltraps
80107cc9:	e9 65 f7 ff ff       	jmp    80107433 <alltraps>

80107cce <vector67>:
.globl vector67
vector67:
  pushl $0
80107cce:	6a 00                	push   $0x0
  pushl $67
80107cd0:	6a 43                	push   $0x43
  jmp alltraps
80107cd2:	e9 5c f7 ff ff       	jmp    80107433 <alltraps>

80107cd7 <vector68>:
.globl vector68
vector68:
  pushl $0
80107cd7:	6a 00                	push   $0x0
  pushl $68
80107cd9:	6a 44                	push   $0x44
  jmp alltraps
80107cdb:	e9 53 f7 ff ff       	jmp    80107433 <alltraps>

80107ce0 <vector69>:
.globl vector69
vector69:
  pushl $0
80107ce0:	6a 00                	push   $0x0
  pushl $69
80107ce2:	6a 45                	push   $0x45
  jmp alltraps
80107ce4:	e9 4a f7 ff ff       	jmp    80107433 <alltraps>

80107ce9 <vector70>:
.globl vector70
vector70:
  pushl $0
80107ce9:	6a 00                	push   $0x0
  pushl $70
80107ceb:	6a 46                	push   $0x46
  jmp alltraps
80107ced:	e9 41 f7 ff ff       	jmp    80107433 <alltraps>

80107cf2 <vector71>:
.globl vector71
vector71:
  pushl $0
80107cf2:	6a 00                	push   $0x0
  pushl $71
80107cf4:	6a 47                	push   $0x47
  jmp alltraps
80107cf6:	e9 38 f7 ff ff       	jmp    80107433 <alltraps>

80107cfb <vector72>:
.globl vector72
vector72:
  pushl $0
80107cfb:	6a 00                	push   $0x0
  pushl $72
80107cfd:	6a 48                	push   $0x48
  jmp alltraps
80107cff:	e9 2f f7 ff ff       	jmp    80107433 <alltraps>

80107d04 <vector73>:
.globl vector73
vector73:
  pushl $0
80107d04:	6a 00                	push   $0x0
  pushl $73
80107d06:	6a 49                	push   $0x49
  jmp alltraps
80107d08:	e9 26 f7 ff ff       	jmp    80107433 <alltraps>

80107d0d <vector74>:
.globl vector74
vector74:
  pushl $0
80107d0d:	6a 00                	push   $0x0
  pushl $74
80107d0f:	6a 4a                	push   $0x4a
  jmp alltraps
80107d11:	e9 1d f7 ff ff       	jmp    80107433 <alltraps>

80107d16 <vector75>:
.globl vector75
vector75:
  pushl $0
80107d16:	6a 00                	push   $0x0
  pushl $75
80107d18:	6a 4b                	push   $0x4b
  jmp alltraps
80107d1a:	e9 14 f7 ff ff       	jmp    80107433 <alltraps>

80107d1f <vector76>:
.globl vector76
vector76:
  pushl $0
80107d1f:	6a 00                	push   $0x0
  pushl $76
80107d21:	6a 4c                	push   $0x4c
  jmp alltraps
80107d23:	e9 0b f7 ff ff       	jmp    80107433 <alltraps>

80107d28 <vector77>:
.globl vector77
vector77:
  pushl $0
80107d28:	6a 00                	push   $0x0
  pushl $77
80107d2a:	6a 4d                	push   $0x4d
  jmp alltraps
80107d2c:	e9 02 f7 ff ff       	jmp    80107433 <alltraps>

80107d31 <vector78>:
.globl vector78
vector78:
  pushl $0
80107d31:	6a 00                	push   $0x0
  pushl $78
80107d33:	6a 4e                	push   $0x4e
  jmp alltraps
80107d35:	e9 f9 f6 ff ff       	jmp    80107433 <alltraps>

80107d3a <vector79>:
.globl vector79
vector79:
  pushl $0
80107d3a:	6a 00                	push   $0x0
  pushl $79
80107d3c:	6a 4f                	push   $0x4f
  jmp alltraps
80107d3e:	e9 f0 f6 ff ff       	jmp    80107433 <alltraps>

80107d43 <vector80>:
.globl vector80
vector80:
  pushl $0
80107d43:	6a 00                	push   $0x0
  pushl $80
80107d45:	6a 50                	push   $0x50
  jmp alltraps
80107d47:	e9 e7 f6 ff ff       	jmp    80107433 <alltraps>

80107d4c <vector81>:
.globl vector81
vector81:
  pushl $0
80107d4c:	6a 00                	push   $0x0
  pushl $81
80107d4e:	6a 51                	push   $0x51
  jmp alltraps
80107d50:	e9 de f6 ff ff       	jmp    80107433 <alltraps>

80107d55 <vector82>:
.globl vector82
vector82:
  pushl $0
80107d55:	6a 00                	push   $0x0
  pushl $82
80107d57:	6a 52                	push   $0x52
  jmp alltraps
80107d59:	e9 d5 f6 ff ff       	jmp    80107433 <alltraps>

80107d5e <vector83>:
.globl vector83
vector83:
  pushl $0
80107d5e:	6a 00                	push   $0x0
  pushl $83
80107d60:	6a 53                	push   $0x53
  jmp alltraps
80107d62:	e9 cc f6 ff ff       	jmp    80107433 <alltraps>

80107d67 <vector84>:
.globl vector84
vector84:
  pushl $0
80107d67:	6a 00                	push   $0x0
  pushl $84
80107d69:	6a 54                	push   $0x54
  jmp alltraps
80107d6b:	e9 c3 f6 ff ff       	jmp    80107433 <alltraps>

80107d70 <vector85>:
.globl vector85
vector85:
  pushl $0
80107d70:	6a 00                	push   $0x0
  pushl $85
80107d72:	6a 55                	push   $0x55
  jmp alltraps
80107d74:	e9 ba f6 ff ff       	jmp    80107433 <alltraps>

80107d79 <vector86>:
.globl vector86
vector86:
  pushl $0
80107d79:	6a 00                	push   $0x0
  pushl $86
80107d7b:	6a 56                	push   $0x56
  jmp alltraps
80107d7d:	e9 b1 f6 ff ff       	jmp    80107433 <alltraps>

80107d82 <vector87>:
.globl vector87
vector87:
  pushl $0
80107d82:	6a 00                	push   $0x0
  pushl $87
80107d84:	6a 57                	push   $0x57
  jmp alltraps
80107d86:	e9 a8 f6 ff ff       	jmp    80107433 <alltraps>

80107d8b <vector88>:
.globl vector88
vector88:
  pushl $0
80107d8b:	6a 00                	push   $0x0
  pushl $88
80107d8d:	6a 58                	push   $0x58
  jmp alltraps
80107d8f:	e9 9f f6 ff ff       	jmp    80107433 <alltraps>

80107d94 <vector89>:
.globl vector89
vector89:
  pushl $0
80107d94:	6a 00                	push   $0x0
  pushl $89
80107d96:	6a 59                	push   $0x59
  jmp alltraps
80107d98:	e9 96 f6 ff ff       	jmp    80107433 <alltraps>

80107d9d <vector90>:
.globl vector90
vector90:
  pushl $0
80107d9d:	6a 00                	push   $0x0
  pushl $90
80107d9f:	6a 5a                	push   $0x5a
  jmp alltraps
80107da1:	e9 8d f6 ff ff       	jmp    80107433 <alltraps>

80107da6 <vector91>:
.globl vector91
vector91:
  pushl $0
80107da6:	6a 00                	push   $0x0
  pushl $91
80107da8:	6a 5b                	push   $0x5b
  jmp alltraps
80107daa:	e9 84 f6 ff ff       	jmp    80107433 <alltraps>

80107daf <vector92>:
.globl vector92
vector92:
  pushl $0
80107daf:	6a 00                	push   $0x0
  pushl $92
80107db1:	6a 5c                	push   $0x5c
  jmp alltraps
80107db3:	e9 7b f6 ff ff       	jmp    80107433 <alltraps>

80107db8 <vector93>:
.globl vector93
vector93:
  pushl $0
80107db8:	6a 00                	push   $0x0
  pushl $93
80107dba:	6a 5d                	push   $0x5d
  jmp alltraps
80107dbc:	e9 72 f6 ff ff       	jmp    80107433 <alltraps>

80107dc1 <vector94>:
.globl vector94
vector94:
  pushl $0
80107dc1:	6a 00                	push   $0x0
  pushl $94
80107dc3:	6a 5e                	push   $0x5e
  jmp alltraps
80107dc5:	e9 69 f6 ff ff       	jmp    80107433 <alltraps>

80107dca <vector95>:
.globl vector95
vector95:
  pushl $0
80107dca:	6a 00                	push   $0x0
  pushl $95
80107dcc:	6a 5f                	push   $0x5f
  jmp alltraps
80107dce:	e9 60 f6 ff ff       	jmp    80107433 <alltraps>

80107dd3 <vector96>:
.globl vector96
vector96:
  pushl $0
80107dd3:	6a 00                	push   $0x0
  pushl $96
80107dd5:	6a 60                	push   $0x60
  jmp alltraps
80107dd7:	e9 57 f6 ff ff       	jmp    80107433 <alltraps>

80107ddc <vector97>:
.globl vector97
vector97:
  pushl $0
80107ddc:	6a 00                	push   $0x0
  pushl $97
80107dde:	6a 61                	push   $0x61
  jmp alltraps
80107de0:	e9 4e f6 ff ff       	jmp    80107433 <alltraps>

80107de5 <vector98>:
.globl vector98
vector98:
  pushl $0
80107de5:	6a 00                	push   $0x0
  pushl $98
80107de7:	6a 62                	push   $0x62
  jmp alltraps
80107de9:	e9 45 f6 ff ff       	jmp    80107433 <alltraps>

80107dee <vector99>:
.globl vector99
vector99:
  pushl $0
80107dee:	6a 00                	push   $0x0
  pushl $99
80107df0:	6a 63                	push   $0x63
  jmp alltraps
80107df2:	e9 3c f6 ff ff       	jmp    80107433 <alltraps>

80107df7 <vector100>:
.globl vector100
vector100:
  pushl $0
80107df7:	6a 00                	push   $0x0
  pushl $100
80107df9:	6a 64                	push   $0x64
  jmp alltraps
80107dfb:	e9 33 f6 ff ff       	jmp    80107433 <alltraps>

80107e00 <vector101>:
.globl vector101
vector101:
  pushl $0
80107e00:	6a 00                	push   $0x0
  pushl $101
80107e02:	6a 65                	push   $0x65
  jmp alltraps
80107e04:	e9 2a f6 ff ff       	jmp    80107433 <alltraps>

80107e09 <vector102>:
.globl vector102
vector102:
  pushl $0
80107e09:	6a 00                	push   $0x0
  pushl $102
80107e0b:	6a 66                	push   $0x66
  jmp alltraps
80107e0d:	e9 21 f6 ff ff       	jmp    80107433 <alltraps>

80107e12 <vector103>:
.globl vector103
vector103:
  pushl $0
80107e12:	6a 00                	push   $0x0
  pushl $103
80107e14:	6a 67                	push   $0x67
  jmp alltraps
80107e16:	e9 18 f6 ff ff       	jmp    80107433 <alltraps>

80107e1b <vector104>:
.globl vector104
vector104:
  pushl $0
80107e1b:	6a 00                	push   $0x0
  pushl $104
80107e1d:	6a 68                	push   $0x68
  jmp alltraps
80107e1f:	e9 0f f6 ff ff       	jmp    80107433 <alltraps>

80107e24 <vector105>:
.globl vector105
vector105:
  pushl $0
80107e24:	6a 00                	push   $0x0
  pushl $105
80107e26:	6a 69                	push   $0x69
  jmp alltraps
80107e28:	e9 06 f6 ff ff       	jmp    80107433 <alltraps>

80107e2d <vector106>:
.globl vector106
vector106:
  pushl $0
80107e2d:	6a 00                	push   $0x0
  pushl $106
80107e2f:	6a 6a                	push   $0x6a
  jmp alltraps
80107e31:	e9 fd f5 ff ff       	jmp    80107433 <alltraps>

80107e36 <vector107>:
.globl vector107
vector107:
  pushl $0
80107e36:	6a 00                	push   $0x0
  pushl $107
80107e38:	6a 6b                	push   $0x6b
  jmp alltraps
80107e3a:	e9 f4 f5 ff ff       	jmp    80107433 <alltraps>

80107e3f <vector108>:
.globl vector108
vector108:
  pushl $0
80107e3f:	6a 00                	push   $0x0
  pushl $108
80107e41:	6a 6c                	push   $0x6c
  jmp alltraps
80107e43:	e9 eb f5 ff ff       	jmp    80107433 <alltraps>

80107e48 <vector109>:
.globl vector109
vector109:
  pushl $0
80107e48:	6a 00                	push   $0x0
  pushl $109
80107e4a:	6a 6d                	push   $0x6d
  jmp alltraps
80107e4c:	e9 e2 f5 ff ff       	jmp    80107433 <alltraps>

80107e51 <vector110>:
.globl vector110
vector110:
  pushl $0
80107e51:	6a 00                	push   $0x0
  pushl $110
80107e53:	6a 6e                	push   $0x6e
  jmp alltraps
80107e55:	e9 d9 f5 ff ff       	jmp    80107433 <alltraps>

80107e5a <vector111>:
.globl vector111
vector111:
  pushl $0
80107e5a:	6a 00                	push   $0x0
  pushl $111
80107e5c:	6a 6f                	push   $0x6f
  jmp alltraps
80107e5e:	e9 d0 f5 ff ff       	jmp    80107433 <alltraps>

80107e63 <vector112>:
.globl vector112
vector112:
  pushl $0
80107e63:	6a 00                	push   $0x0
  pushl $112
80107e65:	6a 70                	push   $0x70
  jmp alltraps
80107e67:	e9 c7 f5 ff ff       	jmp    80107433 <alltraps>

80107e6c <vector113>:
.globl vector113
vector113:
  pushl $0
80107e6c:	6a 00                	push   $0x0
  pushl $113
80107e6e:	6a 71                	push   $0x71
  jmp alltraps
80107e70:	e9 be f5 ff ff       	jmp    80107433 <alltraps>

80107e75 <vector114>:
.globl vector114
vector114:
  pushl $0
80107e75:	6a 00                	push   $0x0
  pushl $114
80107e77:	6a 72                	push   $0x72
  jmp alltraps
80107e79:	e9 b5 f5 ff ff       	jmp    80107433 <alltraps>

80107e7e <vector115>:
.globl vector115
vector115:
  pushl $0
80107e7e:	6a 00                	push   $0x0
  pushl $115
80107e80:	6a 73                	push   $0x73
  jmp alltraps
80107e82:	e9 ac f5 ff ff       	jmp    80107433 <alltraps>

80107e87 <vector116>:
.globl vector116
vector116:
  pushl $0
80107e87:	6a 00                	push   $0x0
  pushl $116
80107e89:	6a 74                	push   $0x74
  jmp alltraps
80107e8b:	e9 a3 f5 ff ff       	jmp    80107433 <alltraps>

80107e90 <vector117>:
.globl vector117
vector117:
  pushl $0
80107e90:	6a 00                	push   $0x0
  pushl $117
80107e92:	6a 75                	push   $0x75
  jmp alltraps
80107e94:	e9 9a f5 ff ff       	jmp    80107433 <alltraps>

80107e99 <vector118>:
.globl vector118
vector118:
  pushl $0
80107e99:	6a 00                	push   $0x0
  pushl $118
80107e9b:	6a 76                	push   $0x76
  jmp alltraps
80107e9d:	e9 91 f5 ff ff       	jmp    80107433 <alltraps>

80107ea2 <vector119>:
.globl vector119
vector119:
  pushl $0
80107ea2:	6a 00                	push   $0x0
  pushl $119
80107ea4:	6a 77                	push   $0x77
  jmp alltraps
80107ea6:	e9 88 f5 ff ff       	jmp    80107433 <alltraps>

80107eab <vector120>:
.globl vector120
vector120:
  pushl $0
80107eab:	6a 00                	push   $0x0
  pushl $120
80107ead:	6a 78                	push   $0x78
  jmp alltraps
80107eaf:	e9 7f f5 ff ff       	jmp    80107433 <alltraps>

80107eb4 <vector121>:
.globl vector121
vector121:
  pushl $0
80107eb4:	6a 00                	push   $0x0
  pushl $121
80107eb6:	6a 79                	push   $0x79
  jmp alltraps
80107eb8:	e9 76 f5 ff ff       	jmp    80107433 <alltraps>

80107ebd <vector122>:
.globl vector122
vector122:
  pushl $0
80107ebd:	6a 00                	push   $0x0
  pushl $122
80107ebf:	6a 7a                	push   $0x7a
  jmp alltraps
80107ec1:	e9 6d f5 ff ff       	jmp    80107433 <alltraps>

80107ec6 <vector123>:
.globl vector123
vector123:
  pushl $0
80107ec6:	6a 00                	push   $0x0
  pushl $123
80107ec8:	6a 7b                	push   $0x7b
  jmp alltraps
80107eca:	e9 64 f5 ff ff       	jmp    80107433 <alltraps>

80107ecf <vector124>:
.globl vector124
vector124:
  pushl $0
80107ecf:	6a 00                	push   $0x0
  pushl $124
80107ed1:	6a 7c                	push   $0x7c
  jmp alltraps
80107ed3:	e9 5b f5 ff ff       	jmp    80107433 <alltraps>

80107ed8 <vector125>:
.globl vector125
vector125:
  pushl $0
80107ed8:	6a 00                	push   $0x0
  pushl $125
80107eda:	6a 7d                	push   $0x7d
  jmp alltraps
80107edc:	e9 52 f5 ff ff       	jmp    80107433 <alltraps>

80107ee1 <vector126>:
.globl vector126
vector126:
  pushl $0
80107ee1:	6a 00                	push   $0x0
  pushl $126
80107ee3:	6a 7e                	push   $0x7e
  jmp alltraps
80107ee5:	e9 49 f5 ff ff       	jmp    80107433 <alltraps>

80107eea <vector127>:
.globl vector127
vector127:
  pushl $0
80107eea:	6a 00                	push   $0x0
  pushl $127
80107eec:	6a 7f                	push   $0x7f
  jmp alltraps
80107eee:	e9 40 f5 ff ff       	jmp    80107433 <alltraps>

80107ef3 <vector128>:
.globl vector128
vector128:
  pushl $0
80107ef3:	6a 00                	push   $0x0
  pushl $128
80107ef5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107efa:	e9 34 f5 ff ff       	jmp    80107433 <alltraps>

80107eff <vector129>:
.globl vector129
vector129:
  pushl $0
80107eff:	6a 00                	push   $0x0
  pushl $129
80107f01:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107f06:	e9 28 f5 ff ff       	jmp    80107433 <alltraps>

80107f0b <vector130>:
.globl vector130
vector130:
  pushl $0
80107f0b:	6a 00                	push   $0x0
  pushl $130
80107f0d:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107f12:	e9 1c f5 ff ff       	jmp    80107433 <alltraps>

80107f17 <vector131>:
.globl vector131
vector131:
  pushl $0
80107f17:	6a 00                	push   $0x0
  pushl $131
80107f19:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107f1e:	e9 10 f5 ff ff       	jmp    80107433 <alltraps>

80107f23 <vector132>:
.globl vector132
vector132:
  pushl $0
80107f23:	6a 00                	push   $0x0
  pushl $132
80107f25:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107f2a:	e9 04 f5 ff ff       	jmp    80107433 <alltraps>

80107f2f <vector133>:
.globl vector133
vector133:
  pushl $0
80107f2f:	6a 00                	push   $0x0
  pushl $133
80107f31:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f36:	e9 f8 f4 ff ff       	jmp    80107433 <alltraps>

80107f3b <vector134>:
.globl vector134
vector134:
  pushl $0
80107f3b:	6a 00                	push   $0x0
  pushl $134
80107f3d:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107f42:	e9 ec f4 ff ff       	jmp    80107433 <alltraps>

80107f47 <vector135>:
.globl vector135
vector135:
  pushl $0
80107f47:	6a 00                	push   $0x0
  pushl $135
80107f49:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107f4e:	e9 e0 f4 ff ff       	jmp    80107433 <alltraps>

80107f53 <vector136>:
.globl vector136
vector136:
  pushl $0
80107f53:	6a 00                	push   $0x0
  pushl $136
80107f55:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107f5a:	e9 d4 f4 ff ff       	jmp    80107433 <alltraps>

80107f5f <vector137>:
.globl vector137
vector137:
  pushl $0
80107f5f:	6a 00                	push   $0x0
  pushl $137
80107f61:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107f66:	e9 c8 f4 ff ff       	jmp    80107433 <alltraps>

80107f6b <vector138>:
.globl vector138
vector138:
  pushl $0
80107f6b:	6a 00                	push   $0x0
  pushl $138
80107f6d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107f72:	e9 bc f4 ff ff       	jmp    80107433 <alltraps>

80107f77 <vector139>:
.globl vector139
vector139:
  pushl $0
80107f77:	6a 00                	push   $0x0
  pushl $139
80107f79:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107f7e:	e9 b0 f4 ff ff       	jmp    80107433 <alltraps>

80107f83 <vector140>:
.globl vector140
vector140:
  pushl $0
80107f83:	6a 00                	push   $0x0
  pushl $140
80107f85:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107f8a:	e9 a4 f4 ff ff       	jmp    80107433 <alltraps>

80107f8f <vector141>:
.globl vector141
vector141:
  pushl $0
80107f8f:	6a 00                	push   $0x0
  pushl $141
80107f91:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107f96:	e9 98 f4 ff ff       	jmp    80107433 <alltraps>

80107f9b <vector142>:
.globl vector142
vector142:
  pushl $0
80107f9b:	6a 00                	push   $0x0
  pushl $142
80107f9d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107fa2:	e9 8c f4 ff ff       	jmp    80107433 <alltraps>

80107fa7 <vector143>:
.globl vector143
vector143:
  pushl $0
80107fa7:	6a 00                	push   $0x0
  pushl $143
80107fa9:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107fae:	e9 80 f4 ff ff       	jmp    80107433 <alltraps>

80107fb3 <vector144>:
.globl vector144
vector144:
  pushl $0
80107fb3:	6a 00                	push   $0x0
  pushl $144
80107fb5:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107fba:	e9 74 f4 ff ff       	jmp    80107433 <alltraps>

80107fbf <vector145>:
.globl vector145
vector145:
  pushl $0
80107fbf:	6a 00                	push   $0x0
  pushl $145
80107fc1:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107fc6:	e9 68 f4 ff ff       	jmp    80107433 <alltraps>

80107fcb <vector146>:
.globl vector146
vector146:
  pushl $0
80107fcb:	6a 00                	push   $0x0
  pushl $146
80107fcd:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107fd2:	e9 5c f4 ff ff       	jmp    80107433 <alltraps>

80107fd7 <vector147>:
.globl vector147
vector147:
  pushl $0
80107fd7:	6a 00                	push   $0x0
  pushl $147
80107fd9:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107fde:	e9 50 f4 ff ff       	jmp    80107433 <alltraps>

80107fe3 <vector148>:
.globl vector148
vector148:
  pushl $0
80107fe3:	6a 00                	push   $0x0
  pushl $148
80107fe5:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107fea:	e9 44 f4 ff ff       	jmp    80107433 <alltraps>

80107fef <vector149>:
.globl vector149
vector149:
  pushl $0
80107fef:	6a 00                	push   $0x0
  pushl $149
80107ff1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107ff6:	e9 38 f4 ff ff       	jmp    80107433 <alltraps>

80107ffb <vector150>:
.globl vector150
vector150:
  pushl $0
80107ffb:	6a 00                	push   $0x0
  pushl $150
80107ffd:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108002:	e9 2c f4 ff ff       	jmp    80107433 <alltraps>

80108007 <vector151>:
.globl vector151
vector151:
  pushl $0
80108007:	6a 00                	push   $0x0
  pushl $151
80108009:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010800e:	e9 20 f4 ff ff       	jmp    80107433 <alltraps>

80108013 <vector152>:
.globl vector152
vector152:
  pushl $0
80108013:	6a 00                	push   $0x0
  pushl $152
80108015:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010801a:	e9 14 f4 ff ff       	jmp    80107433 <alltraps>

8010801f <vector153>:
.globl vector153
vector153:
  pushl $0
8010801f:	6a 00                	push   $0x0
  pushl $153
80108021:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108026:	e9 08 f4 ff ff       	jmp    80107433 <alltraps>

8010802b <vector154>:
.globl vector154
vector154:
  pushl $0
8010802b:	6a 00                	push   $0x0
  pushl $154
8010802d:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108032:	e9 fc f3 ff ff       	jmp    80107433 <alltraps>

80108037 <vector155>:
.globl vector155
vector155:
  pushl $0
80108037:	6a 00                	push   $0x0
  pushl $155
80108039:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010803e:	e9 f0 f3 ff ff       	jmp    80107433 <alltraps>

80108043 <vector156>:
.globl vector156
vector156:
  pushl $0
80108043:	6a 00                	push   $0x0
  pushl $156
80108045:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010804a:	e9 e4 f3 ff ff       	jmp    80107433 <alltraps>

8010804f <vector157>:
.globl vector157
vector157:
  pushl $0
8010804f:	6a 00                	push   $0x0
  pushl $157
80108051:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108056:	e9 d8 f3 ff ff       	jmp    80107433 <alltraps>

8010805b <vector158>:
.globl vector158
vector158:
  pushl $0
8010805b:	6a 00                	push   $0x0
  pushl $158
8010805d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80108062:	e9 cc f3 ff ff       	jmp    80107433 <alltraps>

80108067 <vector159>:
.globl vector159
vector159:
  pushl $0
80108067:	6a 00                	push   $0x0
  pushl $159
80108069:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010806e:	e9 c0 f3 ff ff       	jmp    80107433 <alltraps>

80108073 <vector160>:
.globl vector160
vector160:
  pushl $0
80108073:	6a 00                	push   $0x0
  pushl $160
80108075:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010807a:	e9 b4 f3 ff ff       	jmp    80107433 <alltraps>

8010807f <vector161>:
.globl vector161
vector161:
  pushl $0
8010807f:	6a 00                	push   $0x0
  pushl $161
80108081:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108086:	e9 a8 f3 ff ff       	jmp    80107433 <alltraps>

8010808b <vector162>:
.globl vector162
vector162:
  pushl $0
8010808b:	6a 00                	push   $0x0
  pushl $162
8010808d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80108092:	e9 9c f3 ff ff       	jmp    80107433 <alltraps>

80108097 <vector163>:
.globl vector163
vector163:
  pushl $0
80108097:	6a 00                	push   $0x0
  pushl $163
80108099:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010809e:	e9 90 f3 ff ff       	jmp    80107433 <alltraps>

801080a3 <vector164>:
.globl vector164
vector164:
  pushl $0
801080a3:	6a 00                	push   $0x0
  pushl $164
801080a5:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801080aa:	e9 84 f3 ff ff       	jmp    80107433 <alltraps>

801080af <vector165>:
.globl vector165
vector165:
  pushl $0
801080af:	6a 00                	push   $0x0
  pushl $165
801080b1:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801080b6:	e9 78 f3 ff ff       	jmp    80107433 <alltraps>

801080bb <vector166>:
.globl vector166
vector166:
  pushl $0
801080bb:	6a 00                	push   $0x0
  pushl $166
801080bd:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801080c2:	e9 6c f3 ff ff       	jmp    80107433 <alltraps>

801080c7 <vector167>:
.globl vector167
vector167:
  pushl $0
801080c7:	6a 00                	push   $0x0
  pushl $167
801080c9:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801080ce:	e9 60 f3 ff ff       	jmp    80107433 <alltraps>

801080d3 <vector168>:
.globl vector168
vector168:
  pushl $0
801080d3:	6a 00                	push   $0x0
  pushl $168
801080d5:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801080da:	e9 54 f3 ff ff       	jmp    80107433 <alltraps>

801080df <vector169>:
.globl vector169
vector169:
  pushl $0
801080df:	6a 00                	push   $0x0
  pushl $169
801080e1:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801080e6:	e9 48 f3 ff ff       	jmp    80107433 <alltraps>

801080eb <vector170>:
.globl vector170
vector170:
  pushl $0
801080eb:	6a 00                	push   $0x0
  pushl $170
801080ed:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801080f2:	e9 3c f3 ff ff       	jmp    80107433 <alltraps>

801080f7 <vector171>:
.globl vector171
vector171:
  pushl $0
801080f7:	6a 00                	push   $0x0
  pushl $171
801080f9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801080fe:	e9 30 f3 ff ff       	jmp    80107433 <alltraps>

80108103 <vector172>:
.globl vector172
vector172:
  pushl $0
80108103:	6a 00                	push   $0x0
  pushl $172
80108105:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010810a:	e9 24 f3 ff ff       	jmp    80107433 <alltraps>

8010810f <vector173>:
.globl vector173
vector173:
  pushl $0
8010810f:	6a 00                	push   $0x0
  pushl $173
80108111:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108116:	e9 18 f3 ff ff       	jmp    80107433 <alltraps>

8010811b <vector174>:
.globl vector174
vector174:
  pushl $0
8010811b:	6a 00                	push   $0x0
  pushl $174
8010811d:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108122:	e9 0c f3 ff ff       	jmp    80107433 <alltraps>

80108127 <vector175>:
.globl vector175
vector175:
  pushl $0
80108127:	6a 00                	push   $0x0
  pushl $175
80108129:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010812e:	e9 00 f3 ff ff       	jmp    80107433 <alltraps>

80108133 <vector176>:
.globl vector176
vector176:
  pushl $0
80108133:	6a 00                	push   $0x0
  pushl $176
80108135:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010813a:	e9 f4 f2 ff ff       	jmp    80107433 <alltraps>

8010813f <vector177>:
.globl vector177
vector177:
  pushl $0
8010813f:	6a 00                	push   $0x0
  pushl $177
80108141:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108146:	e9 e8 f2 ff ff       	jmp    80107433 <alltraps>

8010814b <vector178>:
.globl vector178
vector178:
  pushl $0
8010814b:	6a 00                	push   $0x0
  pushl $178
8010814d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108152:	e9 dc f2 ff ff       	jmp    80107433 <alltraps>

80108157 <vector179>:
.globl vector179
vector179:
  pushl $0
80108157:	6a 00                	push   $0x0
  pushl $179
80108159:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010815e:	e9 d0 f2 ff ff       	jmp    80107433 <alltraps>

80108163 <vector180>:
.globl vector180
vector180:
  pushl $0
80108163:	6a 00                	push   $0x0
  pushl $180
80108165:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010816a:	e9 c4 f2 ff ff       	jmp    80107433 <alltraps>

8010816f <vector181>:
.globl vector181
vector181:
  pushl $0
8010816f:	6a 00                	push   $0x0
  pushl $181
80108171:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108176:	e9 b8 f2 ff ff       	jmp    80107433 <alltraps>

8010817b <vector182>:
.globl vector182
vector182:
  pushl $0
8010817b:	6a 00                	push   $0x0
  pushl $182
8010817d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108182:	e9 ac f2 ff ff       	jmp    80107433 <alltraps>

80108187 <vector183>:
.globl vector183
vector183:
  pushl $0
80108187:	6a 00                	push   $0x0
  pushl $183
80108189:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
8010818e:	e9 a0 f2 ff ff       	jmp    80107433 <alltraps>

80108193 <vector184>:
.globl vector184
vector184:
  pushl $0
80108193:	6a 00                	push   $0x0
  pushl $184
80108195:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010819a:	e9 94 f2 ff ff       	jmp    80107433 <alltraps>

8010819f <vector185>:
.globl vector185
vector185:
  pushl $0
8010819f:	6a 00                	push   $0x0
  pushl $185
801081a1:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801081a6:	e9 88 f2 ff ff       	jmp    80107433 <alltraps>

801081ab <vector186>:
.globl vector186
vector186:
  pushl $0
801081ab:	6a 00                	push   $0x0
  pushl $186
801081ad:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801081b2:	e9 7c f2 ff ff       	jmp    80107433 <alltraps>

801081b7 <vector187>:
.globl vector187
vector187:
  pushl $0
801081b7:	6a 00                	push   $0x0
  pushl $187
801081b9:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801081be:	e9 70 f2 ff ff       	jmp    80107433 <alltraps>

801081c3 <vector188>:
.globl vector188
vector188:
  pushl $0
801081c3:	6a 00                	push   $0x0
  pushl $188
801081c5:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801081ca:	e9 64 f2 ff ff       	jmp    80107433 <alltraps>

801081cf <vector189>:
.globl vector189
vector189:
  pushl $0
801081cf:	6a 00                	push   $0x0
  pushl $189
801081d1:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801081d6:	e9 58 f2 ff ff       	jmp    80107433 <alltraps>

801081db <vector190>:
.globl vector190
vector190:
  pushl $0
801081db:	6a 00                	push   $0x0
  pushl $190
801081dd:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801081e2:	e9 4c f2 ff ff       	jmp    80107433 <alltraps>

801081e7 <vector191>:
.globl vector191
vector191:
  pushl $0
801081e7:	6a 00                	push   $0x0
  pushl $191
801081e9:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801081ee:	e9 40 f2 ff ff       	jmp    80107433 <alltraps>

801081f3 <vector192>:
.globl vector192
vector192:
  pushl $0
801081f3:	6a 00                	push   $0x0
  pushl $192
801081f5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801081fa:	e9 34 f2 ff ff       	jmp    80107433 <alltraps>

801081ff <vector193>:
.globl vector193
vector193:
  pushl $0
801081ff:	6a 00                	push   $0x0
  pushl $193
80108201:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108206:	e9 28 f2 ff ff       	jmp    80107433 <alltraps>

8010820b <vector194>:
.globl vector194
vector194:
  pushl $0
8010820b:	6a 00                	push   $0x0
  pushl $194
8010820d:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108212:	e9 1c f2 ff ff       	jmp    80107433 <alltraps>

80108217 <vector195>:
.globl vector195
vector195:
  pushl $0
80108217:	6a 00                	push   $0x0
  pushl $195
80108219:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010821e:	e9 10 f2 ff ff       	jmp    80107433 <alltraps>

80108223 <vector196>:
.globl vector196
vector196:
  pushl $0
80108223:	6a 00                	push   $0x0
  pushl $196
80108225:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010822a:	e9 04 f2 ff ff       	jmp    80107433 <alltraps>

8010822f <vector197>:
.globl vector197
vector197:
  pushl $0
8010822f:	6a 00                	push   $0x0
  pushl $197
80108231:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108236:	e9 f8 f1 ff ff       	jmp    80107433 <alltraps>

8010823b <vector198>:
.globl vector198
vector198:
  pushl $0
8010823b:	6a 00                	push   $0x0
  pushl $198
8010823d:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108242:	e9 ec f1 ff ff       	jmp    80107433 <alltraps>

80108247 <vector199>:
.globl vector199
vector199:
  pushl $0
80108247:	6a 00                	push   $0x0
  pushl $199
80108249:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010824e:	e9 e0 f1 ff ff       	jmp    80107433 <alltraps>

80108253 <vector200>:
.globl vector200
vector200:
  pushl $0
80108253:	6a 00                	push   $0x0
  pushl $200
80108255:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010825a:	e9 d4 f1 ff ff       	jmp    80107433 <alltraps>

8010825f <vector201>:
.globl vector201
vector201:
  pushl $0
8010825f:	6a 00                	push   $0x0
  pushl $201
80108261:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108266:	e9 c8 f1 ff ff       	jmp    80107433 <alltraps>

8010826b <vector202>:
.globl vector202
vector202:
  pushl $0
8010826b:	6a 00                	push   $0x0
  pushl $202
8010826d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108272:	e9 bc f1 ff ff       	jmp    80107433 <alltraps>

80108277 <vector203>:
.globl vector203
vector203:
  pushl $0
80108277:	6a 00                	push   $0x0
  pushl $203
80108279:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010827e:	e9 b0 f1 ff ff       	jmp    80107433 <alltraps>

80108283 <vector204>:
.globl vector204
vector204:
  pushl $0
80108283:	6a 00                	push   $0x0
  pushl $204
80108285:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010828a:	e9 a4 f1 ff ff       	jmp    80107433 <alltraps>

8010828f <vector205>:
.globl vector205
vector205:
  pushl $0
8010828f:	6a 00                	push   $0x0
  pushl $205
80108291:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108296:	e9 98 f1 ff ff       	jmp    80107433 <alltraps>

8010829b <vector206>:
.globl vector206
vector206:
  pushl $0
8010829b:	6a 00                	push   $0x0
  pushl $206
8010829d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801082a2:	e9 8c f1 ff ff       	jmp    80107433 <alltraps>

801082a7 <vector207>:
.globl vector207
vector207:
  pushl $0
801082a7:	6a 00                	push   $0x0
  pushl $207
801082a9:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801082ae:	e9 80 f1 ff ff       	jmp    80107433 <alltraps>

801082b3 <vector208>:
.globl vector208
vector208:
  pushl $0
801082b3:	6a 00                	push   $0x0
  pushl $208
801082b5:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801082ba:	e9 74 f1 ff ff       	jmp    80107433 <alltraps>

801082bf <vector209>:
.globl vector209
vector209:
  pushl $0
801082bf:	6a 00                	push   $0x0
  pushl $209
801082c1:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801082c6:	e9 68 f1 ff ff       	jmp    80107433 <alltraps>

801082cb <vector210>:
.globl vector210
vector210:
  pushl $0
801082cb:	6a 00                	push   $0x0
  pushl $210
801082cd:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801082d2:	e9 5c f1 ff ff       	jmp    80107433 <alltraps>

801082d7 <vector211>:
.globl vector211
vector211:
  pushl $0
801082d7:	6a 00                	push   $0x0
  pushl $211
801082d9:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801082de:	e9 50 f1 ff ff       	jmp    80107433 <alltraps>

801082e3 <vector212>:
.globl vector212
vector212:
  pushl $0
801082e3:	6a 00                	push   $0x0
  pushl $212
801082e5:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801082ea:	e9 44 f1 ff ff       	jmp    80107433 <alltraps>

801082ef <vector213>:
.globl vector213
vector213:
  pushl $0
801082ef:	6a 00                	push   $0x0
  pushl $213
801082f1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801082f6:	e9 38 f1 ff ff       	jmp    80107433 <alltraps>

801082fb <vector214>:
.globl vector214
vector214:
  pushl $0
801082fb:	6a 00                	push   $0x0
  pushl $214
801082fd:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108302:	e9 2c f1 ff ff       	jmp    80107433 <alltraps>

80108307 <vector215>:
.globl vector215
vector215:
  pushl $0
80108307:	6a 00                	push   $0x0
  pushl $215
80108309:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010830e:	e9 20 f1 ff ff       	jmp    80107433 <alltraps>

80108313 <vector216>:
.globl vector216
vector216:
  pushl $0
80108313:	6a 00                	push   $0x0
  pushl $216
80108315:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010831a:	e9 14 f1 ff ff       	jmp    80107433 <alltraps>

8010831f <vector217>:
.globl vector217
vector217:
  pushl $0
8010831f:	6a 00                	push   $0x0
  pushl $217
80108321:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108326:	e9 08 f1 ff ff       	jmp    80107433 <alltraps>

8010832b <vector218>:
.globl vector218
vector218:
  pushl $0
8010832b:	6a 00                	push   $0x0
  pushl $218
8010832d:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108332:	e9 fc f0 ff ff       	jmp    80107433 <alltraps>

80108337 <vector219>:
.globl vector219
vector219:
  pushl $0
80108337:	6a 00                	push   $0x0
  pushl $219
80108339:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010833e:	e9 f0 f0 ff ff       	jmp    80107433 <alltraps>

80108343 <vector220>:
.globl vector220
vector220:
  pushl $0
80108343:	6a 00                	push   $0x0
  pushl $220
80108345:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010834a:	e9 e4 f0 ff ff       	jmp    80107433 <alltraps>

8010834f <vector221>:
.globl vector221
vector221:
  pushl $0
8010834f:	6a 00                	push   $0x0
  pushl $221
80108351:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108356:	e9 d8 f0 ff ff       	jmp    80107433 <alltraps>

8010835b <vector222>:
.globl vector222
vector222:
  pushl $0
8010835b:	6a 00                	push   $0x0
  pushl $222
8010835d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108362:	e9 cc f0 ff ff       	jmp    80107433 <alltraps>

80108367 <vector223>:
.globl vector223
vector223:
  pushl $0
80108367:	6a 00                	push   $0x0
  pushl $223
80108369:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010836e:	e9 c0 f0 ff ff       	jmp    80107433 <alltraps>

80108373 <vector224>:
.globl vector224
vector224:
  pushl $0
80108373:	6a 00                	push   $0x0
  pushl $224
80108375:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010837a:	e9 b4 f0 ff ff       	jmp    80107433 <alltraps>

8010837f <vector225>:
.globl vector225
vector225:
  pushl $0
8010837f:	6a 00                	push   $0x0
  pushl $225
80108381:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108386:	e9 a8 f0 ff ff       	jmp    80107433 <alltraps>

8010838b <vector226>:
.globl vector226
vector226:
  pushl $0
8010838b:	6a 00                	push   $0x0
  pushl $226
8010838d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108392:	e9 9c f0 ff ff       	jmp    80107433 <alltraps>

80108397 <vector227>:
.globl vector227
vector227:
  pushl $0
80108397:	6a 00                	push   $0x0
  pushl $227
80108399:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010839e:	e9 90 f0 ff ff       	jmp    80107433 <alltraps>

801083a3 <vector228>:
.globl vector228
vector228:
  pushl $0
801083a3:	6a 00                	push   $0x0
  pushl $228
801083a5:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801083aa:	e9 84 f0 ff ff       	jmp    80107433 <alltraps>

801083af <vector229>:
.globl vector229
vector229:
  pushl $0
801083af:	6a 00                	push   $0x0
  pushl $229
801083b1:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801083b6:	e9 78 f0 ff ff       	jmp    80107433 <alltraps>

801083bb <vector230>:
.globl vector230
vector230:
  pushl $0
801083bb:	6a 00                	push   $0x0
  pushl $230
801083bd:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801083c2:	e9 6c f0 ff ff       	jmp    80107433 <alltraps>

801083c7 <vector231>:
.globl vector231
vector231:
  pushl $0
801083c7:	6a 00                	push   $0x0
  pushl $231
801083c9:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801083ce:	e9 60 f0 ff ff       	jmp    80107433 <alltraps>

801083d3 <vector232>:
.globl vector232
vector232:
  pushl $0
801083d3:	6a 00                	push   $0x0
  pushl $232
801083d5:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801083da:	e9 54 f0 ff ff       	jmp    80107433 <alltraps>

801083df <vector233>:
.globl vector233
vector233:
  pushl $0
801083df:	6a 00                	push   $0x0
  pushl $233
801083e1:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801083e6:	e9 48 f0 ff ff       	jmp    80107433 <alltraps>

801083eb <vector234>:
.globl vector234
vector234:
  pushl $0
801083eb:	6a 00                	push   $0x0
  pushl $234
801083ed:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801083f2:	e9 3c f0 ff ff       	jmp    80107433 <alltraps>

801083f7 <vector235>:
.globl vector235
vector235:
  pushl $0
801083f7:	6a 00                	push   $0x0
  pushl $235
801083f9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801083fe:	e9 30 f0 ff ff       	jmp    80107433 <alltraps>

80108403 <vector236>:
.globl vector236
vector236:
  pushl $0
80108403:	6a 00                	push   $0x0
  pushl $236
80108405:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010840a:	e9 24 f0 ff ff       	jmp    80107433 <alltraps>

8010840f <vector237>:
.globl vector237
vector237:
  pushl $0
8010840f:	6a 00                	push   $0x0
  pushl $237
80108411:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108416:	e9 18 f0 ff ff       	jmp    80107433 <alltraps>

8010841b <vector238>:
.globl vector238
vector238:
  pushl $0
8010841b:	6a 00                	push   $0x0
  pushl $238
8010841d:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108422:	e9 0c f0 ff ff       	jmp    80107433 <alltraps>

80108427 <vector239>:
.globl vector239
vector239:
  pushl $0
80108427:	6a 00                	push   $0x0
  pushl $239
80108429:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010842e:	e9 00 f0 ff ff       	jmp    80107433 <alltraps>

80108433 <vector240>:
.globl vector240
vector240:
  pushl $0
80108433:	6a 00                	push   $0x0
  pushl $240
80108435:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010843a:	e9 f4 ef ff ff       	jmp    80107433 <alltraps>

8010843f <vector241>:
.globl vector241
vector241:
  pushl $0
8010843f:	6a 00                	push   $0x0
  pushl $241
80108441:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108446:	e9 e8 ef ff ff       	jmp    80107433 <alltraps>

8010844b <vector242>:
.globl vector242
vector242:
  pushl $0
8010844b:	6a 00                	push   $0x0
  pushl $242
8010844d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108452:	e9 dc ef ff ff       	jmp    80107433 <alltraps>

80108457 <vector243>:
.globl vector243
vector243:
  pushl $0
80108457:	6a 00                	push   $0x0
  pushl $243
80108459:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010845e:	e9 d0 ef ff ff       	jmp    80107433 <alltraps>

80108463 <vector244>:
.globl vector244
vector244:
  pushl $0
80108463:	6a 00                	push   $0x0
  pushl $244
80108465:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010846a:	e9 c4 ef ff ff       	jmp    80107433 <alltraps>

8010846f <vector245>:
.globl vector245
vector245:
  pushl $0
8010846f:	6a 00                	push   $0x0
  pushl $245
80108471:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108476:	e9 b8 ef ff ff       	jmp    80107433 <alltraps>

8010847b <vector246>:
.globl vector246
vector246:
  pushl $0
8010847b:	6a 00                	push   $0x0
  pushl $246
8010847d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108482:	e9 ac ef ff ff       	jmp    80107433 <alltraps>

80108487 <vector247>:
.globl vector247
vector247:
  pushl $0
80108487:	6a 00                	push   $0x0
  pushl $247
80108489:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010848e:	e9 a0 ef ff ff       	jmp    80107433 <alltraps>

80108493 <vector248>:
.globl vector248
vector248:
  pushl $0
80108493:	6a 00                	push   $0x0
  pushl $248
80108495:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010849a:	e9 94 ef ff ff       	jmp    80107433 <alltraps>

8010849f <vector249>:
.globl vector249
vector249:
  pushl $0
8010849f:	6a 00                	push   $0x0
  pushl $249
801084a1:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801084a6:	e9 88 ef ff ff       	jmp    80107433 <alltraps>

801084ab <vector250>:
.globl vector250
vector250:
  pushl $0
801084ab:	6a 00                	push   $0x0
  pushl $250
801084ad:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801084b2:	e9 7c ef ff ff       	jmp    80107433 <alltraps>

801084b7 <vector251>:
.globl vector251
vector251:
  pushl $0
801084b7:	6a 00                	push   $0x0
  pushl $251
801084b9:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801084be:	e9 70 ef ff ff       	jmp    80107433 <alltraps>

801084c3 <vector252>:
.globl vector252
vector252:
  pushl $0
801084c3:	6a 00                	push   $0x0
  pushl $252
801084c5:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801084ca:	e9 64 ef ff ff       	jmp    80107433 <alltraps>

801084cf <vector253>:
.globl vector253
vector253:
  pushl $0
801084cf:	6a 00                	push   $0x0
  pushl $253
801084d1:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801084d6:	e9 58 ef ff ff       	jmp    80107433 <alltraps>

801084db <vector254>:
.globl vector254
vector254:
  pushl $0
801084db:	6a 00                	push   $0x0
  pushl $254
801084dd:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801084e2:	e9 4c ef ff ff       	jmp    80107433 <alltraps>

801084e7 <vector255>:
.globl vector255
vector255:
  pushl $0
801084e7:	6a 00                	push   $0x0
  pushl $255
801084e9:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801084ee:	e9 40 ef ff ff       	jmp    80107433 <alltraps>

801084f3 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801084f3:	55                   	push   %ebp
801084f4:	89 e5                	mov    %esp,%ebp
801084f6:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801084f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801084fc:	83 e8 01             	sub    $0x1,%eax
801084ff:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108503:	8b 45 08             	mov    0x8(%ebp),%eax
80108506:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010850a:	8b 45 08             	mov    0x8(%ebp),%eax
8010850d:	c1 e8 10             	shr    $0x10,%eax
80108510:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108514:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108517:	0f 01 10             	lgdtl  (%eax)
}
8010851a:	90                   	nop
8010851b:	c9                   	leave  
8010851c:	c3                   	ret    

8010851d <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010851d:	55                   	push   %ebp
8010851e:	89 e5                	mov    %esp,%ebp
80108520:	83 ec 04             	sub    $0x4,%esp
80108523:	8b 45 08             	mov    0x8(%ebp),%eax
80108526:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010852a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010852e:	0f 00 d8             	ltr    %ax
}
80108531:	90                   	nop
80108532:	c9                   	leave  
80108533:	c3                   	ret    

80108534 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108534:	55                   	push   %ebp
80108535:	89 e5                	mov    %esp,%ebp
80108537:	83 ec 04             	sub    $0x4,%esp
8010853a:	8b 45 08             	mov    0x8(%ebp),%eax
8010853d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108541:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108545:	8e e8                	mov    %eax,%gs
}
80108547:	90                   	nop
80108548:	c9                   	leave  
80108549:	c3                   	ret    

8010854a <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010854a:	55                   	push   %ebp
8010854b:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010854d:	8b 45 08             	mov    0x8(%ebp),%eax
80108550:	0f 22 d8             	mov    %eax,%cr3
}
80108553:	90                   	nop
80108554:	5d                   	pop    %ebp
80108555:	c3                   	ret    

80108556 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108556:	55                   	push   %ebp
80108557:	89 e5                	mov    %esp,%ebp
80108559:	8b 45 08             	mov    0x8(%ebp),%eax
8010855c:	05 00 00 00 80       	add    $0x80000000,%eax
80108561:	5d                   	pop    %ebp
80108562:	c3                   	ret    

80108563 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108563:	55                   	push   %ebp
80108564:	89 e5                	mov    %esp,%ebp
80108566:	8b 45 08             	mov    0x8(%ebp),%eax
80108569:	05 00 00 00 80       	add    $0x80000000,%eax
8010856e:	5d                   	pop    %ebp
8010856f:	c3                   	ret    

80108570 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108570:	55                   	push   %ebp
80108571:	89 e5                	mov    %esp,%ebp
80108573:	53                   	push   %ebx
80108574:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108577:	e8 02 ab ff ff       	call   8010307e <cpunum>
8010857c:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108582:	05 80 33 11 80       	add    $0x80113380,%eax
80108587:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010858a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108596:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010859c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801085a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085aa:	83 e2 f0             	and    $0xfffffff0,%edx
801085ad:	83 ca 0a             	or     $0xa,%edx
801085b0:	88 50 7d             	mov    %dl,0x7d(%eax)
801085b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b6:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085ba:	83 ca 10             	or     $0x10,%edx
801085bd:	88 50 7d             	mov    %dl,0x7d(%eax)
801085c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085c7:	83 e2 9f             	and    $0xffffff9f,%edx
801085ca:	88 50 7d             	mov    %dl,0x7d(%eax)
801085cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801085d4:	83 ca 80             	or     $0xffffff80,%edx
801085d7:	88 50 7d             	mov    %dl,0x7d(%eax)
801085da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085dd:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085e1:	83 ca 0f             	or     $0xf,%edx
801085e4:	88 50 7e             	mov    %dl,0x7e(%eax)
801085e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ea:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085ee:	83 e2 ef             	and    $0xffffffef,%edx
801085f1:	88 50 7e             	mov    %dl,0x7e(%eax)
801085f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801085fb:	83 e2 df             	and    $0xffffffdf,%edx
801085fe:	88 50 7e             	mov    %dl,0x7e(%eax)
80108601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108604:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108608:	83 ca 40             	or     $0x40,%edx
8010860b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010860e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108611:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108615:	83 ca 80             	or     $0xffffff80,%edx
80108618:	88 50 7e             	mov    %dl,0x7e(%eax)
8010861b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861e:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108622:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108625:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010862c:	ff ff 
8010862e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108631:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108638:	00 00 
8010863a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863d:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108647:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010864e:	83 e2 f0             	and    $0xfffffff0,%edx
80108651:	83 ca 02             	or     $0x2,%edx
80108654:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010865a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108664:	83 ca 10             	or     $0x10,%edx
80108667:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010866d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108670:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108677:	83 e2 9f             	and    $0xffffff9f,%edx
8010867a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108683:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010868a:	83 ca 80             	or     $0xffffff80,%edx
8010868d:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108696:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010869d:	83 ca 0f             	or     $0xf,%edx
801086a0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086b0:	83 e2 ef             	and    $0xffffffef,%edx
801086b3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086c3:	83 e2 df             	and    $0xffffffdf,%edx
801086c6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cf:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086d6:	83 ca 40             	or     $0x40,%edx
801086d9:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e2:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801086e9:	83 ca 80             	or     $0xffffff80,%edx
801086ec:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801086f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f5:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801086fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ff:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108706:	ff ff 
80108708:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870b:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108712:	00 00 
80108714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108717:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010871e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108721:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108728:	83 e2 f0             	and    $0xfffffff0,%edx
8010872b:	83 ca 0a             	or     $0xa,%edx
8010872e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108734:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108737:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010873e:	83 ca 10             	or     $0x10,%edx
80108741:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108747:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108751:	83 ca 60             	or     $0x60,%edx
80108754:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010875a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875d:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108764:	83 ca 80             	or     $0xffffff80,%edx
80108767:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010876d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108770:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108777:	83 ca 0f             	or     $0xf,%edx
8010877a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108783:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010878a:	83 e2 ef             	and    $0xffffffef,%edx
8010878d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108796:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010879d:	83 e2 df             	and    $0xffffffdf,%edx
801087a0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087b0:	83 ca 40             	or     $0x40,%edx
801087b3:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087bc:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801087c3:	83 ca 80             	or     $0xffffff80,%edx
801087c6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cf:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801087d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d9:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801087e0:	ff ff 
801087e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e5:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801087ec:	00 00 
801087ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f1:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
801087f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108802:	83 e2 f0             	and    $0xfffffff0,%edx
80108805:	83 ca 02             	or     $0x2,%edx
80108808:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
8010880e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108811:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108818:	83 ca 10             	or     $0x10,%edx
8010881b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108821:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108824:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010882b:	83 ca 60             	or     $0x60,%edx
8010882e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108834:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108837:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010883e:	83 ca 80             	or     $0xffffff80,%edx
80108841:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010884a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108851:	83 ca 0f             	or     $0xf,%edx
80108854:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010885a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108864:	83 e2 ef             	and    $0xffffffef,%edx
80108867:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010886d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108870:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108877:	83 e2 df             	and    $0xffffffdf,%edx
8010887a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108880:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108883:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010888a:	83 ca 40             	or     $0x40,%edx
8010888d:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108896:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010889d:	83 ca 80             	or     $0xffffff80,%edx
801088a0:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801088a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a9:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801088b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b3:	05 b4 00 00 00       	add    $0xb4,%eax
801088b8:	89 c3                	mov    %eax,%ebx
801088ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088bd:	05 b4 00 00 00       	add    $0xb4,%eax
801088c2:	c1 e8 10             	shr    $0x10,%eax
801088c5:	89 c2                	mov    %eax,%edx
801088c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ca:	05 b4 00 00 00       	add    $0xb4,%eax
801088cf:	c1 e8 18             	shr    $0x18,%eax
801088d2:	89 c1                	mov    %eax,%ecx
801088d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d7:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801088de:	00 00 
801088e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e3:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801088ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ed:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
801088fd:	83 e2 f0             	and    $0xfffffff0,%edx
80108900:	83 ca 02             	or     $0x2,%edx
80108903:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108909:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108913:	83 ca 10             	or     $0x10,%edx
80108916:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010891c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010891f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108926:	83 e2 9f             	and    $0xffffff9f,%edx
80108929:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010892f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108932:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108939:	83 ca 80             	or     $0xffffff80,%edx
8010893c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108945:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010894c:	83 e2 f0             	and    $0xfffffff0,%edx
8010894f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108958:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010895f:	83 e2 ef             	and    $0xffffffef,%edx
80108962:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108972:	83 e2 df             	and    $0xffffffdf,%edx
80108975:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010897b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897e:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108985:	83 ca 40             	or     $0x40,%edx
80108988:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010898e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108991:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108998:	83 ca 80             	or     $0xffffff80,%edx
8010899b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801089a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a4:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801089aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ad:	83 c0 70             	add    $0x70,%eax
801089b0:	83 ec 08             	sub    $0x8,%esp
801089b3:	6a 38                	push   $0x38
801089b5:	50                   	push   %eax
801089b6:	e8 38 fb ff ff       	call   801084f3 <lgdt>
801089bb:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801089be:	83 ec 0c             	sub    $0xc,%esp
801089c1:	6a 18                	push   $0x18
801089c3:	e8 6c fb ff ff       	call   80108534 <loadgs>
801089c8:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801089d4:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801089db:	00 00 00 00 
}
801089df:	90                   	nop
801089e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089e3:	c9                   	leave  
801089e4:	c3                   	ret    

801089e5 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801089e5:	55                   	push   %ebp
801089e6:	89 e5                	mov    %esp,%ebp
801089e8:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801089eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801089ee:	c1 e8 16             	shr    $0x16,%eax
801089f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089f8:	8b 45 08             	mov    0x8(%ebp),%eax
801089fb:	01 d0                	add    %edx,%eax
801089fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a03:	8b 00                	mov    (%eax),%eax
80108a05:	83 e0 01             	and    $0x1,%eax
80108a08:	85 c0                	test   %eax,%eax
80108a0a:	74 18                	je     80108a24 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80108a0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a0f:	8b 00                	mov    (%eax),%eax
80108a11:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a16:	50                   	push   %eax
80108a17:	e8 47 fb ff ff       	call   80108563 <p2v>
80108a1c:	83 c4 04             	add    $0x4,%esp
80108a1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a22:	eb 48                	jmp    80108a6c <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108a24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108a28:	74 0e                	je     80108a38 <walkpgdir+0x53>
80108a2a:	e8 e9 a2 ff ff       	call   80102d18 <kalloc>
80108a2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a32:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a36:	75 07                	jne    80108a3f <walkpgdir+0x5a>
      return 0;
80108a38:	b8 00 00 00 00       	mov    $0x0,%eax
80108a3d:	eb 44                	jmp    80108a83 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108a3f:	83 ec 04             	sub    $0x4,%esp
80108a42:	68 00 10 00 00       	push   $0x1000
80108a47:	6a 00                	push   $0x0
80108a49:	ff 75 f4             	pushl  -0xc(%ebp)
80108a4c:	e8 c6 d4 ff ff       	call   80105f17 <memset>
80108a51:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108a54:	83 ec 0c             	sub    $0xc,%esp
80108a57:	ff 75 f4             	pushl  -0xc(%ebp)
80108a5a:	e8 f7 fa ff ff       	call   80108556 <v2p>
80108a5f:	83 c4 10             	add    $0x10,%esp
80108a62:	83 c8 07             	or     $0x7,%eax
80108a65:	89 c2                	mov    %eax,%edx
80108a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a6a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a6f:	c1 e8 0c             	shr    $0xc,%eax
80108a72:	25 ff 03 00 00       	and    $0x3ff,%eax
80108a77:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108a7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a81:	01 d0                	add    %edx,%eax
}
80108a83:	c9                   	leave  
80108a84:	c3                   	ret    

80108a85 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108a85:	55                   	push   %ebp
80108a86:	89 e5                	mov    %esp,%ebp
80108a88:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a8e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108a96:	8b 55 0c             	mov    0xc(%ebp),%edx
80108a99:	8b 45 10             	mov    0x10(%ebp),%eax
80108a9c:	01 d0                	add    %edx,%eax
80108a9e:	83 e8 01             	sub    $0x1,%eax
80108aa1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108aa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108aa9:	83 ec 04             	sub    $0x4,%esp
80108aac:	6a 01                	push   $0x1
80108aae:	ff 75 f4             	pushl  -0xc(%ebp)
80108ab1:	ff 75 08             	pushl  0x8(%ebp)
80108ab4:	e8 2c ff ff ff       	call   801089e5 <walkpgdir>
80108ab9:	83 c4 10             	add    $0x10,%esp
80108abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108abf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ac3:	75 07                	jne    80108acc <mappages+0x47>
      return -1;
80108ac5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108aca:	eb 47                	jmp    80108b13 <mappages+0x8e>
    if(*pte & PTE_P)
80108acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108acf:	8b 00                	mov    (%eax),%eax
80108ad1:	83 e0 01             	and    $0x1,%eax
80108ad4:	85 c0                	test   %eax,%eax
80108ad6:	74 0d                	je     80108ae5 <mappages+0x60>
      panic("remap");
80108ad8:	83 ec 0c             	sub    $0xc,%esp
80108adb:	68 d8 9b 10 80       	push   $0x80109bd8
80108ae0:	e8 81 7a ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80108ae5:	8b 45 18             	mov    0x18(%ebp),%eax
80108ae8:	0b 45 14             	or     0x14(%ebp),%eax
80108aeb:	83 c8 01             	or     $0x1,%eax
80108aee:	89 c2                	mov    %eax,%edx
80108af0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af3:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108afb:	74 10                	je     80108b0d <mappages+0x88>
      break;
    a += PGSIZE;
80108afd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108b04:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108b0b:	eb 9c                	jmp    80108aa9 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80108b0d:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108b0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b13:	c9                   	leave  
80108b14:	c3                   	ret    

80108b15 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108b15:	55                   	push   %ebp
80108b16:	89 e5                	mov    %esp,%ebp
80108b18:	53                   	push   %ebx
80108b19:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108b1c:	e8 f7 a1 ff ff       	call   80102d18 <kalloc>
80108b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b28:	75 0a                	jne    80108b34 <setupkvm+0x1f>
    return 0;
80108b2a:	b8 00 00 00 00       	mov    $0x0,%eax
80108b2f:	e9 8e 00 00 00       	jmp    80108bc2 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108b34:	83 ec 04             	sub    $0x4,%esp
80108b37:	68 00 10 00 00       	push   $0x1000
80108b3c:	6a 00                	push   $0x0
80108b3e:	ff 75 f0             	pushl  -0x10(%ebp)
80108b41:	e8 d1 d3 ff ff       	call   80105f17 <memset>
80108b46:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108b49:	83 ec 0c             	sub    $0xc,%esp
80108b4c:	68 00 00 00 0e       	push   $0xe000000
80108b51:	e8 0d fa ff ff       	call   80108563 <p2v>
80108b56:	83 c4 10             	add    $0x10,%esp
80108b59:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108b5e:	76 0d                	jbe    80108b6d <setupkvm+0x58>
    panic("PHYSTOP too high");
80108b60:	83 ec 0c             	sub    $0xc,%esp
80108b63:	68 de 9b 10 80       	push   $0x80109bde
80108b68:	e8 f9 79 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108b6d:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108b74:	eb 40                	jmp    80108bb6 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b79:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7f:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b85:	8b 58 08             	mov    0x8(%eax),%ebx
80108b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8b:	8b 40 04             	mov    0x4(%eax),%eax
80108b8e:	29 c3                	sub    %eax,%ebx
80108b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b93:	8b 00                	mov    (%eax),%eax
80108b95:	83 ec 0c             	sub    $0xc,%esp
80108b98:	51                   	push   %ecx
80108b99:	52                   	push   %edx
80108b9a:	53                   	push   %ebx
80108b9b:	50                   	push   %eax
80108b9c:	ff 75 f0             	pushl  -0x10(%ebp)
80108b9f:	e8 e1 fe ff ff       	call   80108a85 <mappages>
80108ba4:	83 c4 20             	add    $0x20,%esp
80108ba7:	85 c0                	test   %eax,%eax
80108ba9:	79 07                	jns    80108bb2 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108bab:	b8 00 00 00 00       	mov    $0x0,%eax
80108bb0:	eb 10                	jmp    80108bc2 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108bb2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108bb6:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108bbd:	72 b7                	jb     80108b76 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108bc5:	c9                   	leave  
80108bc6:	c3                   	ret    

80108bc7 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108bc7:	55                   	push   %ebp
80108bc8:	89 e5                	mov    %esp,%ebp
80108bca:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108bcd:	e8 43 ff ff ff       	call   80108b15 <setupkvm>
80108bd2:	a3 58 67 11 80       	mov    %eax,0x80116758
  switchkvm();
80108bd7:	e8 03 00 00 00       	call   80108bdf <switchkvm>
}
80108bdc:	90                   	nop
80108bdd:	c9                   	leave  
80108bde:	c3                   	ret    

80108bdf <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108bdf:	55                   	push   %ebp
80108be0:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108be2:	a1 58 67 11 80       	mov    0x80116758,%eax
80108be7:	50                   	push   %eax
80108be8:	e8 69 f9 ff ff       	call   80108556 <v2p>
80108bed:	83 c4 04             	add    $0x4,%esp
80108bf0:	50                   	push   %eax
80108bf1:	e8 54 f9 ff ff       	call   8010854a <lcr3>
80108bf6:	83 c4 04             	add    $0x4,%esp
}
80108bf9:	90                   	nop
80108bfa:	c9                   	leave  
80108bfb:	c3                   	ret    

80108bfc <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108bfc:	55                   	push   %ebp
80108bfd:	89 e5                	mov    %esp,%ebp
80108bff:	56                   	push   %esi
80108c00:	53                   	push   %ebx
  pushcli();
80108c01:	e8 0b d2 ff ff       	call   80105e11 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108c06:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108c0c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c13:	83 c2 08             	add    $0x8,%edx
80108c16:	89 d6                	mov    %edx,%esi
80108c18:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c1f:	83 c2 08             	add    $0x8,%edx
80108c22:	c1 ea 10             	shr    $0x10,%edx
80108c25:	89 d3                	mov    %edx,%ebx
80108c27:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108c2e:	83 c2 08             	add    $0x8,%edx
80108c31:	c1 ea 18             	shr    $0x18,%edx
80108c34:	89 d1                	mov    %edx,%ecx
80108c36:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108c3d:	67 00 
80108c3f:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108c46:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108c4c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c53:	83 e2 f0             	and    $0xfffffff0,%edx
80108c56:	83 ca 09             	or     $0x9,%edx
80108c59:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c5f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c66:	83 ca 10             	or     $0x10,%edx
80108c69:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c6f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c76:	83 e2 9f             	and    $0xffffff9f,%edx
80108c79:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c7f:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108c86:	83 ca 80             	or     $0xffffff80,%edx
80108c89:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108c8f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108c96:	83 e2 f0             	and    $0xfffffff0,%edx
80108c99:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108c9f:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108ca6:	83 e2 ef             	and    $0xffffffef,%edx
80108ca9:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108caf:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cb6:	83 e2 df             	and    $0xffffffdf,%edx
80108cb9:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cbf:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cc6:	83 ca 40             	or     $0x40,%edx
80108cc9:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108ccf:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108cd6:	83 e2 7f             	and    $0x7f,%edx
80108cd9:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108cdf:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108ce5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108ceb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108cf2:	83 e2 ef             	and    $0xffffffef,%edx
80108cf5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108cfb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d01:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108d07:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d0d:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108d14:	8b 52 08             	mov    0x8(%edx),%edx
80108d17:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108d1d:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108d20:	83 ec 0c             	sub    $0xc,%esp
80108d23:	6a 30                	push   $0x30
80108d25:	e8 f3 f7 ff ff       	call   8010851d <ltr>
80108d2a:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108d2d:	8b 45 08             	mov    0x8(%ebp),%eax
80108d30:	8b 40 04             	mov    0x4(%eax),%eax
80108d33:	85 c0                	test   %eax,%eax
80108d35:	75 0d                	jne    80108d44 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108d37:	83 ec 0c             	sub    $0xc,%esp
80108d3a:	68 ef 9b 10 80       	push   $0x80109bef
80108d3f:	e8 22 78 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108d44:	8b 45 08             	mov    0x8(%ebp),%eax
80108d47:	8b 40 04             	mov    0x4(%eax),%eax
80108d4a:	83 ec 0c             	sub    $0xc,%esp
80108d4d:	50                   	push   %eax
80108d4e:	e8 03 f8 ff ff       	call   80108556 <v2p>
80108d53:	83 c4 10             	add    $0x10,%esp
80108d56:	83 ec 0c             	sub    $0xc,%esp
80108d59:	50                   	push   %eax
80108d5a:	e8 eb f7 ff ff       	call   8010854a <lcr3>
80108d5f:	83 c4 10             	add    $0x10,%esp
  popcli();
80108d62:	e8 ef d0 ff ff       	call   80105e56 <popcli>
}
80108d67:	90                   	nop
80108d68:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108d6b:	5b                   	pop    %ebx
80108d6c:	5e                   	pop    %esi
80108d6d:	5d                   	pop    %ebp
80108d6e:	c3                   	ret    

80108d6f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108d6f:	55                   	push   %ebp
80108d70:	89 e5                	mov    %esp,%ebp
80108d72:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108d75:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108d7c:	76 0d                	jbe    80108d8b <inituvm+0x1c>
    panic("inituvm: more than a page");
80108d7e:	83 ec 0c             	sub    $0xc,%esp
80108d81:	68 03 9c 10 80       	push   $0x80109c03
80108d86:	e8 db 77 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108d8b:	e8 88 9f ff ff       	call   80102d18 <kalloc>
80108d90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108d93:	83 ec 04             	sub    $0x4,%esp
80108d96:	68 00 10 00 00       	push   $0x1000
80108d9b:	6a 00                	push   $0x0
80108d9d:	ff 75 f4             	pushl  -0xc(%ebp)
80108da0:	e8 72 d1 ff ff       	call   80105f17 <memset>
80108da5:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108da8:	83 ec 0c             	sub    $0xc,%esp
80108dab:	ff 75 f4             	pushl  -0xc(%ebp)
80108dae:	e8 a3 f7 ff ff       	call   80108556 <v2p>
80108db3:	83 c4 10             	add    $0x10,%esp
80108db6:	83 ec 0c             	sub    $0xc,%esp
80108db9:	6a 06                	push   $0x6
80108dbb:	50                   	push   %eax
80108dbc:	68 00 10 00 00       	push   $0x1000
80108dc1:	6a 00                	push   $0x0
80108dc3:	ff 75 08             	pushl  0x8(%ebp)
80108dc6:	e8 ba fc ff ff       	call   80108a85 <mappages>
80108dcb:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108dce:	83 ec 04             	sub    $0x4,%esp
80108dd1:	ff 75 10             	pushl  0x10(%ebp)
80108dd4:	ff 75 0c             	pushl  0xc(%ebp)
80108dd7:	ff 75 f4             	pushl  -0xc(%ebp)
80108dda:	e8 f7 d1 ff ff       	call   80105fd6 <memmove>
80108ddf:	83 c4 10             	add    $0x10,%esp
}
80108de2:	90                   	nop
80108de3:	c9                   	leave  
80108de4:	c3                   	ret    

80108de5 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108de5:	55                   	push   %ebp
80108de6:	89 e5                	mov    %esp,%ebp
80108de8:	53                   	push   %ebx
80108de9:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108dec:	8b 45 0c             	mov    0xc(%ebp),%eax
80108def:	25 ff 0f 00 00       	and    $0xfff,%eax
80108df4:	85 c0                	test   %eax,%eax
80108df6:	74 0d                	je     80108e05 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108df8:	83 ec 0c             	sub    $0xc,%esp
80108dfb:	68 20 9c 10 80       	push   $0x80109c20
80108e00:	e8 61 77 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108e05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e0c:	e9 95 00 00 00       	jmp    80108ea6 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108e11:	8b 55 0c             	mov    0xc(%ebp),%edx
80108e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e17:	01 d0                	add    %edx,%eax
80108e19:	83 ec 04             	sub    $0x4,%esp
80108e1c:	6a 00                	push   $0x0
80108e1e:	50                   	push   %eax
80108e1f:	ff 75 08             	pushl  0x8(%ebp)
80108e22:	e8 be fb ff ff       	call   801089e5 <walkpgdir>
80108e27:	83 c4 10             	add    $0x10,%esp
80108e2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e2d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e31:	75 0d                	jne    80108e40 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108e33:	83 ec 0c             	sub    $0xc,%esp
80108e36:	68 43 9c 10 80       	push   $0x80109c43
80108e3b:	e8 26 77 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108e40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e43:	8b 00                	mov    (%eax),%eax
80108e45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e4a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108e4d:	8b 45 18             	mov    0x18(%ebp),%eax
80108e50:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e53:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108e58:	77 0b                	ja     80108e65 <loaduvm+0x80>
      n = sz - i;
80108e5a:	8b 45 18             	mov    0x18(%ebp),%eax
80108e5d:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108e60:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108e63:	eb 07                	jmp    80108e6c <loaduvm+0x87>
    else
      n = PGSIZE;
80108e65:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108e6c:	8b 55 14             	mov    0x14(%ebp),%edx
80108e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e72:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108e75:	83 ec 0c             	sub    $0xc,%esp
80108e78:	ff 75 e8             	pushl  -0x18(%ebp)
80108e7b:	e8 e3 f6 ff ff       	call   80108563 <p2v>
80108e80:	83 c4 10             	add    $0x10,%esp
80108e83:	ff 75 f0             	pushl  -0x10(%ebp)
80108e86:	53                   	push   %ebx
80108e87:	50                   	push   %eax
80108e88:	ff 75 10             	pushl  0x10(%ebp)
80108e8b:	e8 fa 90 ff ff       	call   80101f8a <readi>
80108e90:	83 c4 10             	add    $0x10,%esp
80108e93:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108e96:	74 07                	je     80108e9f <loaduvm+0xba>
      return -1;
80108e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108e9d:	eb 18                	jmp    80108eb7 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108e9f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea9:	3b 45 18             	cmp    0x18(%ebp),%eax
80108eac:	0f 82 5f ff ff ff    	jb     80108e11 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108eb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108eb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108eba:	c9                   	leave  
80108ebb:	c3                   	ret    

80108ebc <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108ebc:	55                   	push   %ebp
80108ebd:	89 e5                	mov    %esp,%ebp
80108ebf:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108ec2:	8b 45 10             	mov    0x10(%ebp),%eax
80108ec5:	85 c0                	test   %eax,%eax
80108ec7:	79 0a                	jns    80108ed3 <allocuvm+0x17>
    return 0;
80108ec9:	b8 00 00 00 00       	mov    $0x0,%eax
80108ece:	e9 b0 00 00 00       	jmp    80108f83 <allocuvm+0xc7>
  if(newsz < oldsz)
80108ed3:	8b 45 10             	mov    0x10(%ebp),%eax
80108ed6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108ed9:	73 08                	jae    80108ee3 <allocuvm+0x27>
    return oldsz;
80108edb:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ede:	e9 a0 00 00 00       	jmp    80108f83 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ee6:	05 ff 0f 00 00       	add    $0xfff,%eax
80108eeb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ef0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108ef3:	eb 7f                	jmp    80108f74 <allocuvm+0xb8>
    mem = kalloc();
80108ef5:	e8 1e 9e ff ff       	call   80102d18 <kalloc>
80108efa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108efd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f01:	75 2b                	jne    80108f2e <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108f03:	83 ec 0c             	sub    $0xc,%esp
80108f06:	68 61 9c 10 80       	push   $0x80109c61
80108f0b:	e8 b6 74 ff ff       	call   801003c6 <cprintf>
80108f10:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108f13:	83 ec 04             	sub    $0x4,%esp
80108f16:	ff 75 0c             	pushl  0xc(%ebp)
80108f19:	ff 75 10             	pushl  0x10(%ebp)
80108f1c:	ff 75 08             	pushl  0x8(%ebp)
80108f1f:	e8 61 00 00 00       	call   80108f85 <deallocuvm>
80108f24:	83 c4 10             	add    $0x10,%esp
      return 0;
80108f27:	b8 00 00 00 00       	mov    $0x0,%eax
80108f2c:	eb 55                	jmp    80108f83 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108f2e:	83 ec 04             	sub    $0x4,%esp
80108f31:	68 00 10 00 00       	push   $0x1000
80108f36:	6a 00                	push   $0x0
80108f38:	ff 75 f0             	pushl  -0x10(%ebp)
80108f3b:	e8 d7 cf ff ff       	call   80105f17 <memset>
80108f40:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108f43:	83 ec 0c             	sub    $0xc,%esp
80108f46:	ff 75 f0             	pushl  -0x10(%ebp)
80108f49:	e8 08 f6 ff ff       	call   80108556 <v2p>
80108f4e:	83 c4 10             	add    $0x10,%esp
80108f51:	89 c2                	mov    %eax,%edx
80108f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f56:	83 ec 0c             	sub    $0xc,%esp
80108f59:	6a 06                	push   $0x6
80108f5b:	52                   	push   %edx
80108f5c:	68 00 10 00 00       	push   $0x1000
80108f61:	50                   	push   %eax
80108f62:	ff 75 08             	pushl  0x8(%ebp)
80108f65:	e8 1b fb ff ff       	call   80108a85 <mappages>
80108f6a:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108f6d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f77:	3b 45 10             	cmp    0x10(%ebp),%eax
80108f7a:	0f 82 75 ff ff ff    	jb     80108ef5 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108f80:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108f83:	c9                   	leave  
80108f84:	c3                   	ret    

80108f85 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108f85:	55                   	push   %ebp
80108f86:	89 e5                	mov    %esp,%ebp
80108f88:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108f8b:	8b 45 10             	mov    0x10(%ebp),%eax
80108f8e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f91:	72 08                	jb     80108f9b <deallocuvm+0x16>
    return oldsz;
80108f93:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f96:	e9 a5 00 00 00       	jmp    80109040 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108f9b:	8b 45 10             	mov    0x10(%ebp),%eax
80108f9e:	05 ff 0f 00 00       	add    $0xfff,%eax
80108fa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108fab:	e9 81 00 00 00       	jmp    80109031 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fb3:	83 ec 04             	sub    $0x4,%esp
80108fb6:	6a 00                	push   $0x0
80108fb8:	50                   	push   %eax
80108fb9:	ff 75 08             	pushl  0x8(%ebp)
80108fbc:	e8 24 fa ff ff       	call   801089e5 <walkpgdir>
80108fc1:	83 c4 10             	add    $0x10,%esp
80108fc4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108fc7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108fcb:	75 09                	jne    80108fd6 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108fcd:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108fd4:	eb 54                	jmp    8010902a <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fd9:	8b 00                	mov    (%eax),%eax
80108fdb:	83 e0 01             	and    $0x1,%eax
80108fde:	85 c0                	test   %eax,%eax
80108fe0:	74 48                	je     8010902a <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108fe2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe5:	8b 00                	mov    (%eax),%eax
80108fe7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fec:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108fef:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ff3:	75 0d                	jne    80109002 <deallocuvm+0x7d>
        panic("kfree");
80108ff5:	83 ec 0c             	sub    $0xc,%esp
80108ff8:	68 79 9c 10 80       	push   $0x80109c79
80108ffd:	e8 64 75 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80109002:	83 ec 0c             	sub    $0xc,%esp
80109005:	ff 75 ec             	pushl  -0x14(%ebp)
80109008:	e8 56 f5 ff ff       	call   80108563 <p2v>
8010900d:	83 c4 10             	add    $0x10,%esp
80109010:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80109013:	83 ec 0c             	sub    $0xc,%esp
80109016:	ff 75 e8             	pushl  -0x18(%ebp)
80109019:	e8 5d 9c ff ff       	call   80102c7b <kfree>
8010901e:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80109021:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109024:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010902a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109034:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109037:	0f 82 73 ff ff ff    	jb     80108fb0 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010903d:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109040:	c9                   	leave  
80109041:	c3                   	ret    

80109042 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80109042:	55                   	push   %ebp
80109043:	89 e5                	mov    %esp,%ebp
80109045:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80109048:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010904c:	75 0d                	jne    8010905b <freevm+0x19>
    panic("freevm: no pgdir");
8010904e:	83 ec 0c             	sub    $0xc,%esp
80109051:	68 7f 9c 10 80       	push   $0x80109c7f
80109056:	e8 0b 75 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010905b:	83 ec 04             	sub    $0x4,%esp
8010905e:	6a 00                	push   $0x0
80109060:	68 00 00 00 80       	push   $0x80000000
80109065:	ff 75 08             	pushl  0x8(%ebp)
80109068:	e8 18 ff ff ff       	call   80108f85 <deallocuvm>
8010906d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80109070:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109077:	eb 4f                	jmp    801090c8 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80109079:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010907c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109083:	8b 45 08             	mov    0x8(%ebp),%eax
80109086:	01 d0                	add    %edx,%eax
80109088:	8b 00                	mov    (%eax),%eax
8010908a:	83 e0 01             	and    $0x1,%eax
8010908d:	85 c0                	test   %eax,%eax
8010908f:	74 33                	je     801090c4 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109094:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010909b:	8b 45 08             	mov    0x8(%ebp),%eax
8010909e:	01 d0                	add    %edx,%eax
801090a0:	8b 00                	mov    (%eax),%eax
801090a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090a7:	83 ec 0c             	sub    $0xc,%esp
801090aa:	50                   	push   %eax
801090ab:	e8 b3 f4 ff ff       	call   80108563 <p2v>
801090b0:	83 c4 10             	add    $0x10,%esp
801090b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801090b6:	83 ec 0c             	sub    $0xc,%esp
801090b9:	ff 75 f0             	pushl  -0x10(%ebp)
801090bc:	e8 ba 9b ff ff       	call   80102c7b <kfree>
801090c1:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801090c4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801090c8:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801090cf:	76 a8                	jbe    80109079 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801090d1:	83 ec 0c             	sub    $0xc,%esp
801090d4:	ff 75 08             	pushl  0x8(%ebp)
801090d7:	e8 9f 9b ff ff       	call   80102c7b <kfree>
801090dc:	83 c4 10             	add    $0x10,%esp
}
801090df:	90                   	nop
801090e0:	c9                   	leave  
801090e1:	c3                   	ret    

801090e2 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801090e2:	55                   	push   %ebp
801090e3:	89 e5                	mov    %esp,%ebp
801090e5:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801090e8:	83 ec 04             	sub    $0x4,%esp
801090eb:	6a 00                	push   $0x0
801090ed:	ff 75 0c             	pushl  0xc(%ebp)
801090f0:	ff 75 08             	pushl  0x8(%ebp)
801090f3:	e8 ed f8 ff ff       	call   801089e5 <walkpgdir>
801090f8:	83 c4 10             	add    $0x10,%esp
801090fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801090fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109102:	75 0d                	jne    80109111 <clearpteu+0x2f>
    panic("clearpteu");
80109104:	83 ec 0c             	sub    $0xc,%esp
80109107:	68 90 9c 10 80       	push   $0x80109c90
8010910c:	e8 55 74 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80109111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109114:	8b 00                	mov    (%eax),%eax
80109116:	83 e0 fb             	and    $0xfffffffb,%eax
80109119:	89 c2                	mov    %eax,%edx
8010911b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911e:	89 10                	mov    %edx,(%eax)
}
80109120:	90                   	nop
80109121:	c9                   	leave  
80109122:	c3                   	ret    

80109123 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80109123:	55                   	push   %ebp
80109124:	89 e5                	mov    %esp,%ebp
80109126:	53                   	push   %ebx
80109127:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010912a:	e8 e6 f9 ff ff       	call   80108b15 <setupkvm>
8010912f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109132:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80109136:	75 0a                	jne    80109142 <copyuvm+0x1f>
    return 0;
80109138:	b8 00 00 00 00       	mov    $0x0,%eax
8010913d:	e9 f8 00 00 00       	jmp    8010923a <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80109142:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109149:	e9 c4 00 00 00       	jmp    80109212 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010914e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109151:	83 ec 04             	sub    $0x4,%esp
80109154:	6a 00                	push   $0x0
80109156:	50                   	push   %eax
80109157:	ff 75 08             	pushl  0x8(%ebp)
8010915a:	e8 86 f8 ff ff       	call   801089e5 <walkpgdir>
8010915f:	83 c4 10             	add    $0x10,%esp
80109162:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109165:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109169:	75 0d                	jne    80109178 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010916b:	83 ec 0c             	sub    $0xc,%esp
8010916e:	68 9a 9c 10 80       	push   $0x80109c9a
80109173:	e8 ee 73 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80109178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010917b:	8b 00                	mov    (%eax),%eax
8010917d:	83 e0 01             	and    $0x1,%eax
80109180:	85 c0                	test   %eax,%eax
80109182:	75 0d                	jne    80109191 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80109184:	83 ec 0c             	sub    $0xc,%esp
80109187:	68 b4 9c 10 80       	push   $0x80109cb4
8010918c:	e8 d5 73 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80109191:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109194:	8b 00                	mov    (%eax),%eax
80109196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010919b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
8010919e:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091a1:	8b 00                	mov    (%eax),%eax
801091a3:	25 ff 0f 00 00       	and    $0xfff,%eax
801091a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801091ab:	e8 68 9b ff ff       	call   80102d18 <kalloc>
801091b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801091b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801091b7:	74 6a                	je     80109223 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801091b9:	83 ec 0c             	sub    $0xc,%esp
801091bc:	ff 75 e8             	pushl  -0x18(%ebp)
801091bf:	e8 9f f3 ff ff       	call   80108563 <p2v>
801091c4:	83 c4 10             	add    $0x10,%esp
801091c7:	83 ec 04             	sub    $0x4,%esp
801091ca:	68 00 10 00 00       	push   $0x1000
801091cf:	50                   	push   %eax
801091d0:	ff 75 e0             	pushl  -0x20(%ebp)
801091d3:	e8 fe cd ff ff       	call   80105fd6 <memmove>
801091d8:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801091db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801091de:	83 ec 0c             	sub    $0xc,%esp
801091e1:	ff 75 e0             	pushl  -0x20(%ebp)
801091e4:	e8 6d f3 ff ff       	call   80108556 <v2p>
801091e9:	83 c4 10             	add    $0x10,%esp
801091ec:	89 c2                	mov    %eax,%edx
801091ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091f1:	83 ec 0c             	sub    $0xc,%esp
801091f4:	53                   	push   %ebx
801091f5:	52                   	push   %edx
801091f6:	68 00 10 00 00       	push   $0x1000
801091fb:	50                   	push   %eax
801091fc:	ff 75 f0             	pushl  -0x10(%ebp)
801091ff:	e8 81 f8 ff ff       	call   80108a85 <mappages>
80109204:	83 c4 20             	add    $0x20,%esp
80109207:	85 c0                	test   %eax,%eax
80109209:	78 1b                	js     80109226 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010920b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109215:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109218:	0f 82 30 ff ff ff    	jb     8010914e <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010921e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109221:	eb 17                	jmp    8010923a <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80109223:	90                   	nop
80109224:	eb 01                	jmp    80109227 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80109226:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80109227:	83 ec 0c             	sub    $0xc,%esp
8010922a:	ff 75 f0             	pushl  -0x10(%ebp)
8010922d:	e8 10 fe ff ff       	call   80109042 <freevm>
80109232:	83 c4 10             	add    $0x10,%esp
  return 0;
80109235:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010923a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010923d:	c9                   	leave  
8010923e:	c3                   	ret    

8010923f <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010923f:	55                   	push   %ebp
80109240:	89 e5                	mov    %esp,%ebp
80109242:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109245:	83 ec 04             	sub    $0x4,%esp
80109248:	6a 00                	push   $0x0
8010924a:	ff 75 0c             	pushl  0xc(%ebp)
8010924d:	ff 75 08             	pushl  0x8(%ebp)
80109250:	e8 90 f7 ff ff       	call   801089e5 <walkpgdir>
80109255:	83 c4 10             	add    $0x10,%esp
80109258:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010925b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010925e:	8b 00                	mov    (%eax),%eax
80109260:	83 e0 01             	and    $0x1,%eax
80109263:	85 c0                	test   %eax,%eax
80109265:	75 07                	jne    8010926e <uva2ka+0x2f>
    return 0;
80109267:	b8 00 00 00 00       	mov    $0x0,%eax
8010926c:	eb 29                	jmp    80109297 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010926e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109271:	8b 00                	mov    (%eax),%eax
80109273:	83 e0 04             	and    $0x4,%eax
80109276:	85 c0                	test   %eax,%eax
80109278:	75 07                	jne    80109281 <uva2ka+0x42>
    return 0;
8010927a:	b8 00 00 00 00       	mov    $0x0,%eax
8010927f:	eb 16                	jmp    80109297 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80109281:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109284:	8b 00                	mov    (%eax),%eax
80109286:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010928b:	83 ec 0c             	sub    $0xc,%esp
8010928e:	50                   	push   %eax
8010928f:	e8 cf f2 ff ff       	call   80108563 <p2v>
80109294:	83 c4 10             	add    $0x10,%esp
}
80109297:	c9                   	leave  
80109298:	c3                   	ret    

80109299 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109299:	55                   	push   %ebp
8010929a:	89 e5                	mov    %esp,%ebp
8010929c:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010929f:	8b 45 10             	mov    0x10(%ebp),%eax
801092a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801092a5:	eb 7f                	jmp    80109326 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801092a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801092aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801092af:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801092b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092b5:	83 ec 08             	sub    $0x8,%esp
801092b8:	50                   	push   %eax
801092b9:	ff 75 08             	pushl  0x8(%ebp)
801092bc:	e8 7e ff ff ff       	call   8010923f <uva2ka>
801092c1:	83 c4 10             	add    $0x10,%esp
801092c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801092c7:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801092cb:	75 07                	jne    801092d4 <copyout+0x3b>
      return -1;
801092cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801092d2:	eb 61                	jmp    80109335 <copyout+0x9c>
    n = PGSIZE - (va - va0);
801092d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801092d7:	2b 45 0c             	sub    0xc(%ebp),%eax
801092da:	05 00 10 00 00       	add    $0x1000,%eax
801092df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801092e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092e5:	3b 45 14             	cmp    0x14(%ebp),%eax
801092e8:	76 06                	jbe    801092f0 <copyout+0x57>
      n = len;
801092ea:	8b 45 14             	mov    0x14(%ebp),%eax
801092ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801092f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801092f3:	2b 45 ec             	sub    -0x14(%ebp),%eax
801092f6:	89 c2                	mov    %eax,%edx
801092f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801092fb:	01 d0                	add    %edx,%eax
801092fd:	83 ec 04             	sub    $0x4,%esp
80109300:	ff 75 f0             	pushl  -0x10(%ebp)
80109303:	ff 75 f4             	pushl  -0xc(%ebp)
80109306:	50                   	push   %eax
80109307:	e8 ca cc ff ff       	call   80105fd6 <memmove>
8010930c:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010930f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109312:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109315:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109318:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010931b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010931e:	05 00 10 00 00       	add    $0x1000,%eax
80109323:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109326:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010932a:	0f 85 77 ff ff ff    	jne    801092a7 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109330:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109335:	c9                   	leave  
80109336:	c3                   	ret    
