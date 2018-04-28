
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
8010002d:	b8 8f 38 10 80       	mov    $0x8010388f,%eax
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
8010003d:	68 24 8a 10 80       	push   $0x80108a24
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 30 53 00 00       	call   8010537c <initlock>
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
801000c1:	e8 d8 52 00 00       	call   8010539e <acquire>
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
8010010c:	e8 f4 52 00 00       	call   80105405 <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 d1 4c 00 00       	call   80104dfd <sleep>
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
80100188:	e8 78 52 00 00       	call   80105405 <release>
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
801001aa:	68 2b 8a 10 80       	push   $0x80108a2b
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
801001e2:	e8 26 27 00 00       	call   8010290d <iderw>
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
80100204:	68 3c 8a 10 80       	push   $0x80108a3c
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
80100223:	e8 e5 26 00 00       	call   8010290d <iderw>
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
80100243:	68 43 8a 10 80       	push   $0x80108a43
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 44 51 00 00       	call   8010539e <acquire>
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
801002b9:	e8 26 4c 00 00       	call   80104ee4 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 37 51 00 00       	call   80105405 <release>
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
801003e2:	e8 b7 4f 00 00       	call   8010539e <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 4a 8a 10 80       	push   $0x80108a4a
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
801004cd:	c7 45 ec 53 8a 10 80 	movl   $0x80108a53,-0x14(%ebp)
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
8010055b:	e8 a5 4e 00 00       	call   80105405 <release>
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
8010058b:	68 5a 8a 10 80       	push   $0x80108a5a
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
801005aa:	68 69 8a 10 80       	push   $0x80108a69
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 90 4e 00 00       	call   80105457 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 6b 8a 10 80       	push   $0x80108a6b
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
801006ca:	68 6f 8a 10 80       	push   $0x80108a6f
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
801006f7:	e8 c4 4f 00 00       	call   801056c0 <memmove>
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
80100721:	e8 db 4e 00 00       	call   80105601 <memset>
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
801007b6:	e8 ef 68 00 00       	call   801070aa <uartputc>
801007bb:	83 c4 10             	add    $0x10,%esp
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	6a 20                	push   $0x20
801007c3:	e8 e2 68 00 00       	call   801070aa <uartputc>
801007c8:	83 c4 10             	add    $0x10,%esp
801007cb:	83 ec 0c             	sub    $0xc,%esp
801007ce:	6a 08                	push   $0x8
801007d0:	e8 d5 68 00 00       	call   801070aa <uartputc>
801007d5:	83 c4 10             	add    $0x10,%esp
801007d8:	eb 0e                	jmp    801007e8 <consputc+0x56>
  } else
    uartputc(c);
801007da:	83 ec 0c             	sub    $0xc,%esp
801007dd:	ff 75 08             	pushl  0x8(%ebp)
801007e0:	e8 c5 68 00 00       	call   801070aa <uartputc>
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
801007fc:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100806:	83 ec 0c             	sub    $0xc,%esp
80100809:	68 e0 c5 10 80       	push   $0x8010c5e0
8010080e:	e8 8b 4b 00 00       	call   8010539e <acquire>
80100813:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100816:	e9 44 01 00 00       	jmp    8010095f <consoleintr+0x166>
    switch(c){
8010081b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010081e:	83 f8 10             	cmp    $0x10,%eax
80100821:	74 1e                	je     80100841 <consoleintr+0x48>
80100823:	83 f8 10             	cmp    $0x10,%eax
80100826:	7f 0a                	jg     80100832 <consoleintr+0x39>
80100828:	83 f8 08             	cmp    $0x8,%eax
8010082b:	74 6b                	je     80100898 <consoleintr+0x9f>
8010082d:	e9 9b 00 00 00       	jmp    801008cd <consoleintr+0xd4>
80100832:	83 f8 15             	cmp    $0x15,%eax
80100835:	74 33                	je     8010086a <consoleintr+0x71>
80100837:	83 f8 7f             	cmp    $0x7f,%eax
8010083a:	74 5c                	je     80100898 <consoleintr+0x9f>
8010083c:	e9 8c 00 00 00       	jmp    801008cd <consoleintr+0xd4>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100841:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100848:	e9 12 01 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010084d:	a1 28 18 11 80       	mov    0x80111828,%eax
80100852:	83 e8 01             	sub    $0x1,%eax
80100855:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
8010085a:	83 ec 0c             	sub    $0xc,%esp
8010085d:	68 00 01 00 00       	push   $0x100
80100862:	e8 2b ff ff ff       	call   80100792 <consputc>
80100867:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	8b 15 28 18 11 80    	mov    0x80111828,%edx
80100870:	a1 24 18 11 80       	mov    0x80111824,%eax
80100875:	39 c2                	cmp    %eax,%edx
80100877:	0f 84 e2 00 00 00    	je     8010095f <consoleintr+0x166>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010087d:	a1 28 18 11 80       	mov    0x80111828,%eax
80100882:	83 e8 01             	sub    $0x1,%eax
80100885:	83 e0 7f             	and    $0x7f,%eax
80100888:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010088f:	3c 0a                	cmp    $0xa,%al
80100891:	75 ba                	jne    8010084d <consoleintr+0x54>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100893:	e9 c7 00 00 00       	jmp    8010095f <consoleintr+0x166>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100898:	8b 15 28 18 11 80    	mov    0x80111828,%edx
8010089e:	a1 24 18 11 80       	mov    0x80111824,%eax
801008a3:	39 c2                	cmp    %eax,%edx
801008a5:	0f 84 b4 00 00 00    	je     8010095f <consoleintr+0x166>
        input.e--;
801008ab:	a1 28 18 11 80       	mov    0x80111828,%eax
801008b0:	83 e8 01             	sub    $0x1,%eax
801008b3:	a3 28 18 11 80       	mov    %eax,0x80111828
        consputc(BACKSPACE);
801008b8:	83 ec 0c             	sub    $0xc,%esp
801008bb:	68 00 01 00 00       	push   $0x100
801008c0:	e8 cd fe ff ff       	call   80100792 <consputc>
801008c5:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008c8:	e9 92 00 00 00       	jmp    8010095f <consoleintr+0x166>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d1:	0f 84 87 00 00 00    	je     8010095e <consoleintr+0x165>
801008d7:	8b 15 28 18 11 80    	mov    0x80111828,%edx
801008dd:	a1 20 18 11 80       	mov    0x80111820,%eax
801008e2:	29 c2                	sub    %eax,%edx
801008e4:	89 d0                	mov    %edx,%eax
801008e6:	83 f8 7f             	cmp    $0x7f,%eax
801008e9:	77 73                	ja     8010095e <consoleintr+0x165>
        c = (c == '\r') ? '\n' : c;
801008eb:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008ef:	74 05                	je     801008f6 <consoleintr+0xfd>
801008f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f4:	eb 05                	jmp    801008fb <consoleintr+0x102>
801008f6:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008fe:	a1 28 18 11 80       	mov    0x80111828,%eax
80100903:	8d 50 01             	lea    0x1(%eax),%edx
80100906:	89 15 28 18 11 80    	mov    %edx,0x80111828
8010090c:	83 e0 7f             	and    $0x7f,%eax
8010090f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100912:	88 90 a0 17 11 80    	mov    %dl,-0x7feee860(%eax)
        consputc(c);
80100918:	83 ec 0c             	sub    $0xc,%esp
8010091b:	ff 75 f0             	pushl  -0x10(%ebp)
8010091e:	e8 6f fe ff ff       	call   80100792 <consputc>
80100923:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100926:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092a:	74 18                	je     80100944 <consoleintr+0x14b>
8010092c:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100930:	74 12                	je     80100944 <consoleintr+0x14b>
80100932:	a1 28 18 11 80       	mov    0x80111828,%eax
80100937:	8b 15 20 18 11 80    	mov    0x80111820,%edx
8010093d:	83 ea 80             	sub    $0xffffff80,%edx
80100940:	39 d0                	cmp    %edx,%eax
80100942:	75 1a                	jne    8010095e <consoleintr+0x165>
          input.w = input.e;
80100944:	a1 28 18 11 80       	mov    0x80111828,%eax
80100949:	a3 24 18 11 80       	mov    %eax,0x80111824
          wakeup(&input.r);
8010094e:	83 ec 0c             	sub    $0xc,%esp
80100951:	68 20 18 11 80       	push   $0x80111820
80100956:	e8 89 45 00 00       	call   80104ee4 <wakeup>
8010095b:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095e:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
8010095f:	8b 45 08             	mov    0x8(%ebp),%eax
80100962:	ff d0                	call   *%eax
80100964:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100967:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010096b:	0f 89 aa fe ff ff    	jns    8010081b <consoleintr+0x22>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100971:	83 ec 0c             	sub    $0xc,%esp
80100974:	68 e0 c5 10 80       	push   $0x8010c5e0
80100979:	e8 87 4a 00 00       	call   80105405 <release>
8010097e:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100981:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100985:	74 05                	je     8010098c <consoleintr+0x193>
    procdump();  // now call procdump() wo. cons.lock held
80100987:	e8 29 48 00 00       	call   801051b5 <procdump>
  }
}
8010098c:	90                   	nop
8010098d:	c9                   	leave  
8010098e:	c3                   	ret    

8010098f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010098f:	55                   	push   %ebp
80100990:	89 e5                	mov    %esp,%ebp
80100992:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100995:	83 ec 0c             	sub    $0xc,%esp
80100998:	ff 75 08             	pushl  0x8(%ebp)
8010099b:	e8 28 11 00 00       	call   80101ac8 <iunlock>
801009a0:	83 c4 10             	add    $0x10,%esp
  target = n;
801009a3:	8b 45 10             	mov    0x10(%ebp),%eax
801009a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009a9:	83 ec 0c             	sub    $0xc,%esp
801009ac:	68 e0 c5 10 80       	push   $0x8010c5e0
801009b1:	e8 e8 49 00 00       	call   8010539e <acquire>
801009b6:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009b9:	e9 ac 00 00 00       	jmp    80100a6a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009c4:	8b 40 24             	mov    0x24(%eax),%eax
801009c7:	85 c0                	test   %eax,%eax
801009c9:	74 28                	je     801009f3 <consoleread+0x64>
        release(&cons.lock);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	68 e0 c5 10 80       	push   $0x8010c5e0
801009d3:	e8 2d 4a 00 00       	call   80105405 <release>
801009d8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009db:	83 ec 0c             	sub    $0xc,%esp
801009de:	ff 75 08             	pushl  0x8(%ebp)
801009e1:	e8 84 0f 00 00       	call   8010196a <ilock>
801009e6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009ee:	e9 ab 00 00 00       	jmp    80100a9e <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
801009f3:	83 ec 08             	sub    $0x8,%esp
801009f6:	68 e0 c5 10 80       	push   $0x8010c5e0
801009fb:	68 20 18 11 80       	push   $0x80111820
80100a00:	e8 f8 43 00 00       	call   80104dfd <sleep>
80100a05:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100a08:	8b 15 20 18 11 80    	mov    0x80111820,%edx
80100a0e:	a1 24 18 11 80       	mov    0x80111824,%eax
80100a13:	39 c2                	cmp    %eax,%edx
80100a15:	74 a7                	je     801009be <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a17:	a1 20 18 11 80       	mov    0x80111820,%eax
80100a1c:	8d 50 01             	lea    0x1(%eax),%edx
80100a1f:	89 15 20 18 11 80    	mov    %edx,0x80111820
80100a25:	83 e0 7f             	and    $0x7f,%eax
80100a28:	0f b6 80 a0 17 11 80 	movzbl -0x7feee860(%eax),%eax
80100a2f:	0f be c0             	movsbl %al,%eax
80100a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a35:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a39:	75 17                	jne    80100a52 <consoleread+0xc3>
      if(n < target){
80100a3b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a3e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a41:	73 2f                	jae    80100a72 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a43:	a1 20 18 11 80       	mov    0x80111820,%eax
80100a48:	83 e8 01             	sub    $0x1,%eax
80100a4b:	a3 20 18 11 80       	mov    %eax,0x80111820
      }
      break;
80100a50:	eb 20                	jmp    80100a72 <consoleread+0xe3>
    }
    *dst++ = c;
80100a52:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a55:	8d 50 01             	lea    0x1(%eax),%edx
80100a58:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a5e:	88 10                	mov    %dl,(%eax)
    --n;
80100a60:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a64:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a68:	74 0b                	je     80100a75 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100a6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a6e:	7f 98                	jg     80100a08 <consoleread+0x79>
80100a70:	eb 04                	jmp    80100a76 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a72:	90                   	nop
80100a73:	eb 01                	jmp    80100a76 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a75:	90                   	nop
  }
  release(&cons.lock);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a7e:	e8 82 49 00 00       	call   80105405 <release>
80100a83:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a86:	83 ec 0c             	sub    $0xc,%esp
80100a89:	ff 75 08             	pushl  0x8(%ebp)
80100a8c:	e8 d9 0e 00 00       	call   8010196a <ilock>
80100a91:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a94:	8b 45 10             	mov    0x10(%ebp),%eax
80100a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a9a:	29 c2                	sub    %eax,%edx
80100a9c:	89 d0                	mov    %edx,%eax
}
80100a9e:	c9                   	leave  
80100a9f:	c3                   	ret    

80100aa0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa0:	55                   	push   %ebp
80100aa1:	89 e5                	mov    %esp,%ebp
80100aa3:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aa6:	83 ec 0c             	sub    $0xc,%esp
80100aa9:	ff 75 08             	pushl  0x8(%ebp)
80100aac:	e8 17 10 00 00       	call   80101ac8 <iunlock>
80100ab1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ab4:	83 ec 0c             	sub    $0xc,%esp
80100ab7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100abc:	e8 dd 48 00 00       	call   8010539e <acquire>
80100ac1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ac4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100acb:	eb 21                	jmp    80100aee <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100acd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ad3:	01 d0                	add    %edx,%eax
80100ad5:	0f b6 00             	movzbl (%eax),%eax
80100ad8:	0f be c0             	movsbl %al,%eax
80100adb:	0f b6 c0             	movzbl %al,%eax
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ab fc ff ff       	call   80100792 <consputc>
80100ae7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100af4:	7c d7                	jl     80100acd <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afe:	e8 02 49 00 00       	call   80105405 <release>
80100b03:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	ff 75 08             	pushl  0x8(%ebp)
80100b0c:	e8 59 0e 00 00       	call   8010196a <ilock>
80100b11:	83 c4 10             	add    $0x10,%esp

  return n;
80100b14:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b17:	c9                   	leave  
80100b18:	c3                   	ret    

80100b19 <consoleinit>:

void
consoleinit(void)
{
80100b19:	55                   	push   %ebp
80100b1a:	89 e5                	mov    %esp,%ebp
80100b1c:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b1f:	83 ec 08             	sub    $0x8,%esp
80100b22:	68 82 8a 10 80       	push   $0x80108a82
80100b27:	68 e0 c5 10 80       	push   $0x8010c5e0
80100b2c:	e8 4b 48 00 00       	call   8010537c <initlock>
80100b31:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b34:	c7 05 ec 21 11 80 a0 	movl   $0x80100aa0,0x801121ec
80100b3b:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b3e:	c7 05 e8 21 11 80 8f 	movl   $0x8010098f,0x801121e8
80100b45:	09 10 80 
  cons.locking = 1;
80100b48:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100b4f:	00 00 00 

  picenable(IRQ_KBD);
80100b52:	83 ec 0c             	sub    $0xc,%esp
80100b55:	6a 01                	push   $0x1
80100b57:	e8 cf 33 00 00       	call   80103f2b <picenable>
80100b5c:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b5f:	83 ec 08             	sub    $0x8,%esp
80100b62:	6a 00                	push   $0x0
80100b64:	6a 01                	push   $0x1
80100b66:	e8 6f 1f 00 00       	call   80102ada <ioapicenable>
80100b6b:	83 c4 10             	add    $0x10,%esp
}
80100b6e:	90                   	nop
80100b6f:	c9                   	leave  
80100b70:	c3                   	ret    

80100b71 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b71:	55                   	push   %ebp
80100b72:	89 e5                	mov    %esp,%ebp
80100b74:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b7a:	e8 ce 29 00 00       	call   8010354d <begin_op>
  if((ip = namei(path)) == 0){
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	ff 75 08             	pushl  0x8(%ebp)
80100b85:	e8 9e 19 00 00       	call   80102528 <namei>
80100b8a:	83 c4 10             	add    $0x10,%esp
80100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b90:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b94:	75 0f                	jne    80100ba5 <exec+0x34>
    end_op();
80100b96:	e8 3e 2a 00 00       	call   801035d9 <end_op>
    return -1;
80100b9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ba0:	e9 ce 03 00 00       	jmp    80100f73 <exec+0x402>
  }
  ilock(ip);
80100ba5:	83 ec 0c             	sub    $0xc,%esp
80100ba8:	ff 75 d8             	pushl  -0x28(%ebp)
80100bab:	e8 ba 0d 00 00       	call   8010196a <ilock>
80100bb0:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bb3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100bba:	6a 34                	push   $0x34
80100bbc:	6a 00                	push   $0x0
80100bbe:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bc4:	50                   	push   %eax
80100bc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100bc8:	e8 0b 13 00 00       	call   80101ed8 <readi>
80100bcd:	83 c4 10             	add    $0x10,%esp
80100bd0:	83 f8 33             	cmp    $0x33,%eax
80100bd3:	0f 86 49 03 00 00    	jbe    80100f22 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bd9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bdf:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100be4:	0f 85 3b 03 00 00    	jne    80100f25 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bea:	e8 10 76 00 00       	call   801081ff <setupkvm>
80100bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bf2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bf6:	0f 84 2c 03 00 00    	je     80100f28 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100bfc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c03:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c0a:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c10:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c13:	e9 ab 00 00 00       	jmp    80100cc3 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c1b:	6a 20                	push   $0x20
80100c1d:	50                   	push   %eax
80100c1e:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c24:	50                   	push   %eax
80100c25:	ff 75 d8             	pushl  -0x28(%ebp)
80100c28:	e8 ab 12 00 00       	call   80101ed8 <readi>
80100c2d:	83 c4 10             	add    $0x10,%esp
80100c30:	83 f8 20             	cmp    $0x20,%eax
80100c33:	0f 85 f2 02 00 00    	jne    80100f2b <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c39:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c3f:	83 f8 01             	cmp    $0x1,%eax
80100c42:	75 71                	jne    80100cb5 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c44:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c4a:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c50:	39 c2                	cmp    %eax,%edx
80100c52:	0f 82 d6 02 00 00    	jb     80100f2e <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c58:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c5e:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c64:	01 d0                	add    %edx,%eax
80100c66:	83 ec 04             	sub    $0x4,%esp
80100c69:	50                   	push   %eax
80100c6a:	ff 75 e0             	pushl  -0x20(%ebp)
80100c6d:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c70:	e8 31 79 00 00       	call   801085a6 <allocuvm>
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c7f:	0f 84 ac 02 00 00    	je     80100f31 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c85:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c8b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c91:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c97:	83 ec 0c             	sub    $0xc,%esp
80100c9a:	52                   	push   %edx
80100c9b:	50                   	push   %eax
80100c9c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c9f:	51                   	push   %ecx
80100ca0:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ca3:	e8 27 78 00 00       	call   801084cf <loaduvm>
80100ca8:	83 c4 20             	add    $0x20,%esp
80100cab:	85 c0                	test   %eax,%eax
80100cad:	0f 88 81 02 00 00    	js     80100f34 <exec+0x3c3>
80100cb3:	eb 01                	jmp    80100cb6 <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100cb5:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb6:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100cba:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cbd:	83 c0 20             	add    $0x20,%eax
80100cc0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cc3:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cca:	0f b7 c0             	movzwl %ax,%eax
80100ccd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cd0:	0f 8f 42 ff ff ff    	jg     80100c18 <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cd6:	83 ec 0c             	sub    $0xc,%esp
80100cd9:	ff 75 d8             	pushl  -0x28(%ebp)
80100cdc:	e8 49 0f 00 00       	call   80101c2a <iunlockput>
80100ce1:	83 c4 10             	add    $0x10,%esp
  end_op();
80100ce4:	e8 f0 28 00 00       	call   801035d9 <end_op>
  ip = 0;
80100ce9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cf0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cf3:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cf8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100cfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d03:	05 00 20 00 00       	add    $0x2000,%eax
80100d08:	83 ec 04             	sub    $0x4,%esp
80100d0b:	50                   	push   %eax
80100d0c:	ff 75 e0             	pushl  -0x20(%ebp)
80100d0f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d12:	e8 8f 78 00 00       	call   801085a6 <allocuvm>
80100d17:	83 c4 10             	add    $0x10,%esp
80100d1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d1d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d21:	0f 84 10 02 00 00    	je     80100f37 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d2a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d2f:	83 ec 08             	sub    $0x8,%esp
80100d32:	50                   	push   %eax
80100d33:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d36:	e8 91 7a 00 00       	call   801087cc <clearpteu>
80100d3b:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d3e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d41:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d44:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d4b:	e9 96 00 00 00       	jmp    80100de6 <exec+0x275>
    if(argc >= MAXARG)
80100d50:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d54:	0f 87 e0 01 00 00    	ja     80100f3a <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d64:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d67:	01 d0                	add    %edx,%eax
80100d69:	8b 00                	mov    (%eax),%eax
80100d6b:	83 ec 0c             	sub    $0xc,%esp
80100d6e:	50                   	push   %eax
80100d6f:	e8 da 4a 00 00       	call   8010584e <strlen>
80100d74:	83 c4 10             	add    $0x10,%esp
80100d77:	89 c2                	mov    %eax,%edx
80100d79:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d7c:	29 d0                	sub    %edx,%eax
80100d7e:	83 e8 01             	sub    $0x1,%eax
80100d81:	83 e0 fc             	and    $0xfffffffc,%eax
80100d84:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 ad 4a 00 00       	call   8010584e <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	83 c0 01             	add    $0x1,%eax
80100da7:	89 c1                	mov    %eax,%ecx
80100da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100db3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100db6:	01 d0                	add    %edx,%eax
80100db8:	8b 00                	mov    (%eax),%eax
80100dba:	51                   	push   %ecx
80100dbb:	50                   	push   %eax
80100dbc:	ff 75 dc             	pushl  -0x24(%ebp)
80100dbf:	ff 75 d4             	pushl  -0x2c(%ebp)
80100dc2:	e8 bc 7b 00 00       	call   80108983 <copyout>
80100dc7:	83 c4 10             	add    $0x10,%esp
80100dca:	85 c0                	test   %eax,%eax
80100dcc:	0f 88 6b 01 00 00    	js     80100f3d <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100dd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd5:	8d 50 03             	lea    0x3(%eax),%edx
80100dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ddb:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100de2:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df3:	01 d0                	add    %edx,%eax
80100df5:	8b 00                	mov    (%eax),%eax
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 85 51 ff ff ff    	jne    80100d50 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	83 c0 03             	add    $0x3,%eax
80100e05:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e0c:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e10:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e17:	ff ff ff 
  ustack[1] = argc;
80100e1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1d:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e26:	83 c0 01             	add    $0x1,%eax
80100e29:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e33:	29 d0                	sub    %edx,%eax
80100e35:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3e:	83 c0 04             	add    $0x4,%eax
80100e41:	c1 e0 02             	shl    $0x2,%eax
80100e44:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	83 c0 04             	add    $0x4,%eax
80100e4d:	c1 e0 02             	shl    $0x2,%eax
80100e50:	50                   	push   %eax
80100e51:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e57:	50                   	push   %eax
80100e58:	ff 75 dc             	pushl  -0x24(%ebp)
80100e5b:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e5e:	e8 20 7b 00 00       	call   80108983 <copyout>
80100e63:	83 c4 10             	add    $0x10,%esp
80100e66:	85 c0                	test   %eax,%eax
80100e68:	0f 88 d2 00 00 00    	js     80100f40 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80100e71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e7a:	eb 17                	jmp    80100e93 <exec+0x322>
    if(*s == '/')
80100e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7f:	0f b6 00             	movzbl (%eax),%eax
80100e82:	3c 2f                	cmp    $0x2f,%al
80100e84:	75 09                	jne    80100e8f <exec+0x31e>
      last = s+1;
80100e86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e89:	83 c0 01             	add    $0x1,%eax
80100e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e8f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e96:	0f b6 00             	movzbl (%eax),%eax
80100e99:	84 c0                	test   %al,%al
80100e9b:	75 df                	jne    80100e7c <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e9d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea3:	83 c0 6c             	add    $0x6c,%eax
80100ea6:	83 ec 04             	sub    $0x4,%esp
80100ea9:	6a 10                	push   $0x10
80100eab:	ff 75 f0             	pushl  -0x10(%ebp)
80100eae:	50                   	push   %eax
80100eaf:	e8 50 49 00 00       	call   80105804 <safestrcpy>
80100eb4:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100eb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ebd:	8b 40 04             	mov    0x4(%eax),%eax
80100ec0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ec3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ecc:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100ecf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ed8:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100eda:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee0:	8b 40 18             	mov    0x18(%eax),%eax
80100ee3:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ee9:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100eec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef2:	8b 40 18             	mov    0x18(%eax),%eax
80100ef5:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ef8:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100efb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f01:	83 ec 0c             	sub    $0xc,%esp
80100f04:	50                   	push   %eax
80100f05:	e8 dc 73 00 00       	call   801082e6 <switchuvm>
80100f0a:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	ff 75 d0             	pushl  -0x30(%ebp)
80100f13:	e8 14 78 00 00       	call   8010872c <freevm>
80100f18:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80100f20:	eb 51                	jmp    80100f73 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f22:	90                   	nop
80100f23:	eb 1c                	jmp    80100f41 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f25:	90                   	nop
80100f26:	eb 19                	jmp    80100f41 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f28:	90                   	nop
80100f29:	eb 16                	jmp    80100f41 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f2b:	90                   	nop
80100f2c:	eb 13                	jmp    80100f41 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f2e:	90                   	nop
80100f2f:	eb 10                	jmp    80100f41 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f31:	90                   	nop
80100f32:	eb 0d                	jmp    80100f41 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f34:	90                   	nop
80100f35:	eb 0a                	jmp    80100f41 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f37:	90                   	nop
80100f38:	eb 07                	jmp    80100f41 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f3a:	90                   	nop
80100f3b:	eb 04                	jmp    80100f41 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f3d:	90                   	nop
80100f3e:	eb 01                	jmp    80100f41 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f40:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f41:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f45:	74 0e                	je     80100f55 <exec+0x3e4>
    freevm(pgdir);
80100f47:	83 ec 0c             	sub    $0xc,%esp
80100f4a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f4d:	e8 da 77 00 00       	call   8010872c <freevm>
80100f52:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f55:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f59:	74 13                	je     80100f6e <exec+0x3fd>
    iunlockput(ip);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 d8             	pushl  -0x28(%ebp)
80100f61:	e8 c4 0c 00 00       	call   80101c2a <iunlockput>
80100f66:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f69:	e8 6b 26 00 00       	call   801035d9 <end_op>
  }
  return -1;
80100f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f73:	c9                   	leave  
80100f74:	c3                   	ret    

80100f75 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f75:	55                   	push   %ebp
80100f76:	89 e5                	mov    %esp,%ebp
80100f78:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f7b:	83 ec 08             	sub    $0x8,%esp
80100f7e:	68 8a 8a 10 80       	push   $0x80108a8a
80100f83:	68 40 18 11 80       	push   $0x80111840
80100f88:	e8 ef 43 00 00       	call   8010537c <initlock>
80100f8d:	83 c4 10             	add    $0x10,%esp
}
80100f90:	90                   	nop
80100f91:	c9                   	leave  
80100f92:	c3                   	ret    

80100f93 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f93:	55                   	push   %ebp
80100f94:	89 e5                	mov    %esp,%ebp
80100f96:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f99:	83 ec 0c             	sub    $0xc,%esp
80100f9c:	68 40 18 11 80       	push   $0x80111840
80100fa1:	e8 f8 43 00 00       	call   8010539e <acquire>
80100fa6:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fa9:	c7 45 f4 74 18 11 80 	movl   $0x80111874,-0xc(%ebp)
80100fb0:	eb 2d                	jmp    80100fdf <filealloc+0x4c>
    if(f->ref == 0){
80100fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fb5:	8b 40 04             	mov    0x4(%eax),%eax
80100fb8:	85 c0                	test   %eax,%eax
80100fba:	75 1f                	jne    80100fdb <filealloc+0x48>
      f->ref = 1;
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fc6:	83 ec 0c             	sub    $0xc,%esp
80100fc9:	68 40 18 11 80       	push   $0x80111840
80100fce:	e8 32 44 00 00       	call   80105405 <release>
80100fd3:	83 c4 10             	add    $0x10,%esp
      return f;
80100fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd9:	eb 23                	jmp    80100ffe <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fdb:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fdf:	b8 d4 21 11 80       	mov    $0x801121d4,%eax
80100fe4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fe7:	72 c9                	jb     80100fb2 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fe9:	83 ec 0c             	sub    $0xc,%esp
80100fec:	68 40 18 11 80       	push   $0x80111840
80100ff1:	e8 0f 44 00 00       	call   80105405 <release>
80100ff6:	83 c4 10             	add    $0x10,%esp
  return 0;
80100ff9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100ffe:	c9                   	leave  
80100fff:	c3                   	ret    

80101000 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101000:	55                   	push   %ebp
80101001:	89 e5                	mov    %esp,%ebp
80101003:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101006:	83 ec 0c             	sub    $0xc,%esp
80101009:	68 40 18 11 80       	push   $0x80111840
8010100e:	e8 8b 43 00 00       	call   8010539e <acquire>
80101013:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101016:	8b 45 08             	mov    0x8(%ebp),%eax
80101019:	8b 40 04             	mov    0x4(%eax),%eax
8010101c:	85 c0                	test   %eax,%eax
8010101e:	7f 0d                	jg     8010102d <filedup+0x2d>
    panic("filedup");
80101020:	83 ec 0c             	sub    $0xc,%esp
80101023:	68 91 8a 10 80       	push   $0x80108a91
80101028:	e8 39 f5 ff ff       	call   80100566 <panic>
  f->ref++;
8010102d:	8b 45 08             	mov    0x8(%ebp),%eax
80101030:	8b 40 04             	mov    0x4(%eax),%eax
80101033:	8d 50 01             	lea    0x1(%eax),%edx
80101036:	8b 45 08             	mov    0x8(%ebp),%eax
80101039:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 40 18 11 80       	push   $0x80111840
80101044:	e8 bc 43 00 00       	call   80105405 <release>
80101049:	83 c4 10             	add    $0x10,%esp
  return f;
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010104f:	c9                   	leave  
80101050:	c3                   	ret    

80101051 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101051:	55                   	push   %ebp
80101052:	89 e5                	mov    %esp,%ebp
80101054:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101057:	83 ec 0c             	sub    $0xc,%esp
8010105a:	68 40 18 11 80       	push   $0x80111840
8010105f:	e8 3a 43 00 00       	call   8010539e <acquire>
80101064:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	8b 40 04             	mov    0x4(%eax),%eax
8010106d:	85 c0                	test   %eax,%eax
8010106f:	7f 0d                	jg     8010107e <fileclose+0x2d>
    panic("fileclose");
80101071:	83 ec 0c             	sub    $0xc,%esp
80101074:	68 99 8a 10 80       	push   $0x80108a99
80101079:	e8 e8 f4 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
8010107e:	8b 45 08             	mov    0x8(%ebp),%eax
80101081:	8b 40 04             	mov    0x4(%eax),%eax
80101084:	8d 50 ff             	lea    -0x1(%eax),%edx
80101087:	8b 45 08             	mov    0x8(%ebp),%eax
8010108a:	89 50 04             	mov    %edx,0x4(%eax)
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8b 40 04             	mov    0x4(%eax),%eax
80101093:	85 c0                	test   %eax,%eax
80101095:	7e 15                	jle    801010ac <fileclose+0x5b>
    release(&ftable.lock);
80101097:	83 ec 0c             	sub    $0xc,%esp
8010109a:	68 40 18 11 80       	push   $0x80111840
8010109f:	e8 61 43 00 00       	call   80105405 <release>
801010a4:	83 c4 10             	add    $0x10,%esp
801010a7:	e9 8b 00 00 00       	jmp    80101137 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010ac:	8b 45 08             	mov    0x8(%ebp),%eax
801010af:	8b 10                	mov    (%eax),%edx
801010b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010b4:	8b 50 04             	mov    0x4(%eax),%edx
801010b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010ba:	8b 50 08             	mov    0x8(%eax),%edx
801010bd:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010c0:	8b 50 0c             	mov    0xc(%eax),%edx
801010c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010c6:	8b 50 10             	mov    0x10(%eax),%edx
801010c9:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010cc:	8b 40 14             	mov    0x14(%eax),%eax
801010cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010dc:	8b 45 08             	mov    0x8(%ebp),%eax
801010df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010e5:	83 ec 0c             	sub    $0xc,%esp
801010e8:	68 40 18 11 80       	push   $0x80111840
801010ed:	e8 13 43 00 00       	call   80105405 <release>
801010f2:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010f8:	83 f8 01             	cmp    $0x1,%eax
801010fb:	75 19                	jne    80101116 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010fd:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101101:	0f be d0             	movsbl %al,%edx
80101104:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101107:	83 ec 08             	sub    $0x8,%esp
8010110a:	52                   	push   %edx
8010110b:	50                   	push   %eax
8010110c:	e8 83 30 00 00       	call   80104194 <pipeclose>
80101111:	83 c4 10             	add    $0x10,%esp
80101114:	eb 21                	jmp    80101137 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101116:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101119:	83 f8 02             	cmp    $0x2,%eax
8010111c:	75 19                	jne    80101137 <fileclose+0xe6>
    begin_op();
8010111e:	e8 2a 24 00 00       	call   8010354d <begin_op>
    iput(ff.ip);
80101123:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101126:	83 ec 0c             	sub    $0xc,%esp
80101129:	50                   	push   %eax
8010112a:	e8 0b 0a 00 00       	call   80101b3a <iput>
8010112f:	83 c4 10             	add    $0x10,%esp
    end_op();
80101132:	e8 a2 24 00 00       	call   801035d9 <end_op>
  }
}
80101137:	c9                   	leave  
80101138:	c3                   	ret    

80101139 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101139:	55                   	push   %ebp
8010113a:	89 e5                	mov    %esp,%ebp
8010113c:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010113f:	8b 45 08             	mov    0x8(%ebp),%eax
80101142:	8b 00                	mov    (%eax),%eax
80101144:	83 f8 02             	cmp    $0x2,%eax
80101147:	75 40                	jne    80101189 <filestat+0x50>
    ilock(f->ip);
80101149:	8b 45 08             	mov    0x8(%ebp),%eax
8010114c:	8b 40 10             	mov    0x10(%eax),%eax
8010114f:	83 ec 0c             	sub    $0xc,%esp
80101152:	50                   	push   %eax
80101153:	e8 12 08 00 00       	call   8010196a <ilock>
80101158:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010115b:	8b 45 08             	mov    0x8(%ebp),%eax
8010115e:	8b 40 10             	mov    0x10(%eax),%eax
80101161:	83 ec 08             	sub    $0x8,%esp
80101164:	ff 75 0c             	pushl  0xc(%ebp)
80101167:	50                   	push   %eax
80101168:	e8 25 0d 00 00       	call   80101e92 <stati>
8010116d:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 40 10             	mov    0x10(%eax),%eax
80101176:	83 ec 0c             	sub    $0xc,%esp
80101179:	50                   	push   %eax
8010117a:	e8 49 09 00 00       	call   80101ac8 <iunlock>
8010117f:	83 c4 10             	add    $0x10,%esp
    return 0;
80101182:	b8 00 00 00 00       	mov    $0x0,%eax
80101187:	eb 05                	jmp    8010118e <filestat+0x55>
  }
  return -1;
80101189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010118e:	c9                   	leave  
8010118f:	c3                   	ret    

80101190 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101190:	55                   	push   %ebp
80101191:	89 e5                	mov    %esp,%ebp
80101193:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101196:	8b 45 08             	mov    0x8(%ebp),%eax
80101199:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010119d:	84 c0                	test   %al,%al
8010119f:	75 0a                	jne    801011ab <fileread+0x1b>
    return -1;
801011a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011a6:	e9 9b 00 00 00       	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ab:	8b 45 08             	mov    0x8(%ebp),%eax
801011ae:	8b 00                	mov    (%eax),%eax
801011b0:	83 f8 01             	cmp    $0x1,%eax
801011b3:	75 1a                	jne    801011cf <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011b5:	8b 45 08             	mov    0x8(%ebp),%eax
801011b8:	8b 40 0c             	mov    0xc(%eax),%eax
801011bb:	83 ec 04             	sub    $0x4,%esp
801011be:	ff 75 10             	pushl  0x10(%ebp)
801011c1:	ff 75 0c             	pushl  0xc(%ebp)
801011c4:	50                   	push   %eax
801011c5:	e8 72 31 00 00       	call   8010433c <piperead>
801011ca:	83 c4 10             	add    $0x10,%esp
801011cd:	eb 77                	jmp    80101246 <fileread+0xb6>
  if(f->type == FD_INODE){
801011cf:	8b 45 08             	mov    0x8(%ebp),%eax
801011d2:	8b 00                	mov    (%eax),%eax
801011d4:	83 f8 02             	cmp    $0x2,%eax
801011d7:	75 60                	jne    80101239 <fileread+0xa9>
    ilock(f->ip);
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	83 ec 0c             	sub    $0xc,%esp
801011e2:	50                   	push   %eax
801011e3:	e8 82 07 00 00       	call   8010196a <ilock>
801011e8:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011ee:	8b 45 08             	mov    0x8(%ebp),%eax
801011f1:	8b 50 14             	mov    0x14(%eax),%edx
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	8b 40 10             	mov    0x10(%eax),%eax
801011fa:	51                   	push   %ecx
801011fb:	52                   	push   %edx
801011fc:	ff 75 0c             	pushl  0xc(%ebp)
801011ff:	50                   	push   %eax
80101200:	e8 d3 0c 00 00       	call   80101ed8 <readi>
80101205:	83 c4 10             	add    $0x10,%esp
80101208:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010120b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010120f:	7e 11                	jle    80101222 <fileread+0x92>
      f->off += r;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	8b 50 14             	mov    0x14(%eax),%edx
80101217:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121a:	01 c2                	add    %eax,%edx
8010121c:	8b 45 08             	mov    0x8(%ebp),%eax
8010121f:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101222:	8b 45 08             	mov    0x8(%ebp),%eax
80101225:	8b 40 10             	mov    0x10(%eax),%eax
80101228:	83 ec 0c             	sub    $0xc,%esp
8010122b:	50                   	push   %eax
8010122c:	e8 97 08 00 00       	call   80101ac8 <iunlock>
80101231:	83 c4 10             	add    $0x10,%esp
    return r;
80101234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101237:	eb 0d                	jmp    80101246 <fileread+0xb6>
  }
  panic("fileread");
80101239:	83 ec 0c             	sub    $0xc,%esp
8010123c:	68 a3 8a 10 80       	push   $0x80108aa3
80101241:	e8 20 f3 ff ff       	call   80100566 <panic>
}
80101246:	c9                   	leave  
80101247:	c3                   	ret    

80101248 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101248:	55                   	push   %ebp
80101249:	89 e5                	mov    %esp,%ebp
8010124b:	53                   	push   %ebx
8010124c:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101256:	84 c0                	test   %al,%al
80101258:	75 0a                	jne    80101264 <filewrite+0x1c>
    return -1;
8010125a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010125f:	e9 1b 01 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_PIPE)
80101264:	8b 45 08             	mov    0x8(%ebp),%eax
80101267:	8b 00                	mov    (%eax),%eax
80101269:	83 f8 01             	cmp    $0x1,%eax
8010126c:	75 1d                	jne    8010128b <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010126e:	8b 45 08             	mov    0x8(%ebp),%eax
80101271:	8b 40 0c             	mov    0xc(%eax),%eax
80101274:	83 ec 04             	sub    $0x4,%esp
80101277:	ff 75 10             	pushl  0x10(%ebp)
8010127a:	ff 75 0c             	pushl  0xc(%ebp)
8010127d:	50                   	push   %eax
8010127e:	e8 bb 2f 00 00       	call   8010423e <pipewrite>
80101283:	83 c4 10             	add    $0x10,%esp
80101286:	e9 f4 00 00 00       	jmp    8010137f <filewrite+0x137>
  if(f->type == FD_INODE){
8010128b:	8b 45 08             	mov    0x8(%ebp),%eax
8010128e:	8b 00                	mov    (%eax),%eax
80101290:	83 f8 02             	cmp    $0x2,%eax
80101293:	0f 85 d9 00 00 00    	jne    80101372 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101299:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012a7:	e9 a3 00 00 00       	jmp    8010134f <filewrite+0x107>
      int n1 = n - i;
801012ac:	8b 45 10             	mov    0x10(%ebp),%eax
801012af:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012b8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012bb:	7e 06                	jle    801012c3 <filewrite+0x7b>
        n1 = max;
801012bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012c0:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012c3:	e8 85 22 00 00       	call   8010354d <begin_op>
      ilock(f->ip);
801012c8:	8b 45 08             	mov    0x8(%ebp),%eax
801012cb:	8b 40 10             	mov    0x10(%eax),%eax
801012ce:	83 ec 0c             	sub    $0xc,%esp
801012d1:	50                   	push   %eax
801012d2:	e8 93 06 00 00       	call   8010196a <ilock>
801012d7:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012da:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 50 14             	mov    0x14(%eax),%edx
801012e3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801012e9:	01 c3                	add    %eax,%ebx
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 40 10             	mov    0x10(%eax),%eax
801012f1:	51                   	push   %ecx
801012f2:	52                   	push   %edx
801012f3:	53                   	push   %ebx
801012f4:	50                   	push   %eax
801012f5:	e8 35 0d 00 00       	call   8010202f <writei>
801012fa:	83 c4 10             	add    $0x10,%esp
801012fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101300:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101304:	7e 11                	jle    80101317 <filewrite+0xcf>
        f->off += r;
80101306:	8b 45 08             	mov    0x8(%ebp),%eax
80101309:	8b 50 14             	mov    0x14(%eax),%edx
8010130c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010130f:	01 c2                	add    %eax,%edx
80101311:	8b 45 08             	mov    0x8(%ebp),%eax
80101314:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101317:	8b 45 08             	mov    0x8(%ebp),%eax
8010131a:	8b 40 10             	mov    0x10(%eax),%eax
8010131d:	83 ec 0c             	sub    $0xc,%esp
80101320:	50                   	push   %eax
80101321:	e8 a2 07 00 00       	call   80101ac8 <iunlock>
80101326:	83 c4 10             	add    $0x10,%esp
      end_op();
80101329:	e8 ab 22 00 00       	call   801035d9 <end_op>

      if(r < 0)
8010132e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101332:	78 29                	js     8010135d <filewrite+0x115>
        break;
      if(r != n1)
80101334:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101337:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010133a:	74 0d                	je     80101349 <filewrite+0x101>
        panic("short filewrite");
8010133c:	83 ec 0c             	sub    $0xc,%esp
8010133f:	68 ac 8a 10 80       	push   $0x80108aac
80101344:	e8 1d f2 ff ff       	call   80100566 <panic>
      i += r;
80101349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010134c:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101352:	3b 45 10             	cmp    0x10(%ebp),%eax
80101355:	0f 8c 51 ff ff ff    	jl     801012ac <filewrite+0x64>
8010135b:	eb 01                	jmp    8010135e <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
8010135d:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
8010135e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101361:	3b 45 10             	cmp    0x10(%ebp),%eax
80101364:	75 05                	jne    8010136b <filewrite+0x123>
80101366:	8b 45 10             	mov    0x10(%ebp),%eax
80101369:	eb 14                	jmp    8010137f <filewrite+0x137>
8010136b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101370:	eb 0d                	jmp    8010137f <filewrite+0x137>
  }
  panic("filewrite");
80101372:	83 ec 0c             	sub    $0xc,%esp
80101375:	68 bc 8a 10 80       	push   $0x80108abc
8010137a:	e8 e7 f1 ff ff       	call   80100566 <panic>
}
8010137f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101382:	c9                   	leave  
80101383:	c3                   	ret    

80101384 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101384:	55                   	push   %ebp
80101385:	89 e5                	mov    %esp,%ebp
80101387:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010138a:	8b 45 08             	mov    0x8(%ebp),%eax
8010138d:	83 ec 08             	sub    $0x8,%esp
80101390:	6a 01                	push   $0x1
80101392:	50                   	push   %eax
80101393:	e8 1e ee ff ff       	call   801001b6 <bread>
80101398:	83 c4 10             	add    $0x10,%esp
8010139b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
8010139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a1:	83 c0 18             	add    $0x18,%eax
801013a4:	83 ec 04             	sub    $0x4,%esp
801013a7:	6a 1c                	push   $0x1c
801013a9:	50                   	push   %eax
801013aa:	ff 75 0c             	pushl  0xc(%ebp)
801013ad:	e8 0e 43 00 00       	call   801056c0 <memmove>
801013b2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013b5:	83 ec 0c             	sub    $0xc,%esp
801013b8:	ff 75 f4             	pushl  -0xc(%ebp)
801013bb:	e8 6e ee ff ff       	call   8010022e <brelse>
801013c0:	83 c4 10             	add    $0x10,%esp
}
801013c3:	90                   	nop
801013c4:	c9                   	leave  
801013c5:	c3                   	ret    

801013c6 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013c6:	55                   	push   %ebp
801013c7:	89 e5                	mov    %esp,%ebp
801013c9:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801013cf:	8b 45 08             	mov    0x8(%ebp),%eax
801013d2:	83 ec 08             	sub    $0x8,%esp
801013d5:	52                   	push   %edx
801013d6:	50                   	push   %eax
801013d7:	e8 da ed ff ff       	call   801001b6 <bread>
801013dc:	83 c4 10             	add    $0x10,%esp
801013df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e5:	83 c0 18             	add    $0x18,%eax
801013e8:	83 ec 04             	sub    $0x4,%esp
801013eb:	68 00 02 00 00       	push   $0x200
801013f0:	6a 00                	push   $0x0
801013f2:	50                   	push   %eax
801013f3:	e8 09 42 00 00       	call   80105601 <memset>
801013f8:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013fb:	83 ec 0c             	sub    $0xc,%esp
801013fe:	ff 75 f4             	pushl  -0xc(%ebp)
80101401:	e8 7f 23 00 00       	call   80103785 <log_write>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	pushl  -0xc(%ebp)
8010140f:	e8 1a ee ff ff       	call   8010022e <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave  
80101419:	c3                   	ret    

8010141a <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101420:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101427:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010142e:	e9 13 01 00 00       	jmp    80101546 <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101436:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010143c:	85 c0                	test   %eax,%eax
8010143e:	0f 48 c2             	cmovs  %edx,%eax
80101441:	c1 f8 0c             	sar    $0xc,%eax
80101444:	89 c2                	mov    %eax,%edx
80101446:	a1 58 22 11 80       	mov    0x80112258,%eax
8010144b:	01 d0                	add    %edx,%eax
8010144d:	83 ec 08             	sub    $0x8,%esp
80101450:	50                   	push   %eax
80101451:	ff 75 08             	pushl  0x8(%ebp)
80101454:	e8 5d ed ff ff       	call   801001b6 <bread>
80101459:	83 c4 10             	add    $0x10,%esp
8010145c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010145f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101466:	e9 a6 00 00 00       	jmp    80101511 <balloc+0xf7>
      m = 1 << (bi % 8);
8010146b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146e:	99                   	cltd   
8010146f:	c1 ea 1d             	shr    $0x1d,%edx
80101472:	01 d0                	add    %edx,%eax
80101474:	83 e0 07             	and    $0x7,%eax
80101477:	29 d0                	sub    %edx,%eax
80101479:	ba 01 00 00 00       	mov    $0x1,%edx
8010147e:	89 c1                	mov    %eax,%ecx
80101480:	d3 e2                	shl    %cl,%edx
80101482:	89 d0                	mov    %edx,%eax
80101484:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101487:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010148a:	8d 50 07             	lea    0x7(%eax),%edx
8010148d:	85 c0                	test   %eax,%eax
8010148f:	0f 48 c2             	cmovs  %edx,%eax
80101492:	c1 f8 03             	sar    $0x3,%eax
80101495:	89 c2                	mov    %eax,%edx
80101497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010149a:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010149f:	0f b6 c0             	movzbl %al,%eax
801014a2:	23 45 e8             	and    -0x18(%ebp),%eax
801014a5:	85 c0                	test   %eax,%eax
801014a7:	75 64                	jne    8010150d <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
801014a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ac:	8d 50 07             	lea    0x7(%eax),%edx
801014af:	85 c0                	test   %eax,%eax
801014b1:	0f 48 c2             	cmovs  %edx,%eax
801014b4:	c1 f8 03             	sar    $0x3,%eax
801014b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014ba:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014bf:	89 d1                	mov    %edx,%ecx
801014c1:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c4:	09 ca                	or     %ecx,%edx
801014c6:	89 d1                	mov    %edx,%ecx
801014c8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014cb:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014cf:	83 ec 0c             	sub    $0xc,%esp
801014d2:	ff 75 ec             	pushl  -0x14(%ebp)
801014d5:	e8 ab 22 00 00       	call   80103785 <log_write>
801014da:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014dd:	83 ec 0c             	sub    $0xc,%esp
801014e0:	ff 75 ec             	pushl  -0x14(%ebp)
801014e3:	e8 46 ed ff ff       	call   8010022e <brelse>
801014e8:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f1:	01 c2                	add    %eax,%edx
801014f3:	8b 45 08             	mov    0x8(%ebp),%eax
801014f6:	83 ec 08             	sub    $0x8,%esp
801014f9:	52                   	push   %edx
801014fa:	50                   	push   %eax
801014fb:	e8 c6 fe ff ff       	call   801013c6 <bzero>
80101500:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101503:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101506:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101509:	01 d0                	add    %edx,%eax
8010150b:	eb 57                	jmp    80101564 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010150d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101511:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101518:	7f 17                	jg     80101531 <balloc+0x117>
8010151a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010151d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101520:	01 d0                	add    %edx,%eax
80101522:	89 c2                	mov    %eax,%edx
80101524:	a1 40 22 11 80       	mov    0x80112240,%eax
80101529:	39 c2                	cmp    %eax,%edx
8010152b:	0f 82 3a ff ff ff    	jb     8010146b <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101531:	83 ec 0c             	sub    $0xc,%esp
80101534:	ff 75 ec             	pushl  -0x14(%ebp)
80101537:	e8 f2 ec ff ff       	call   8010022e <brelse>
8010153c:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010153f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101546:	8b 15 40 22 11 80    	mov    0x80112240,%edx
8010154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154f:	39 c2                	cmp    %eax,%edx
80101551:	0f 87 dc fe ff ff    	ja     80101433 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101557:	83 ec 0c             	sub    $0xc,%esp
8010155a:	68 c8 8a 10 80       	push   $0x80108ac8
8010155f:	e8 02 f0 ff ff       	call   80100566 <panic>
}
80101564:	c9                   	leave  
80101565:	c3                   	ret    

80101566 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101566:	55                   	push   %ebp
80101567:	89 e5                	mov    %esp,%ebp
80101569:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
8010156c:	83 ec 08             	sub    $0x8,%esp
8010156f:	68 40 22 11 80       	push   $0x80112240
80101574:	ff 75 08             	pushl  0x8(%ebp)
80101577:	e8 08 fe ff ff       	call   80101384 <readsb>
8010157c:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
8010157f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101582:	c1 e8 0c             	shr    $0xc,%eax
80101585:	89 c2                	mov    %eax,%edx
80101587:	a1 58 22 11 80       	mov    0x80112258,%eax
8010158c:	01 c2                	add    %eax,%edx
8010158e:	8b 45 08             	mov    0x8(%ebp),%eax
80101591:	83 ec 08             	sub    $0x8,%esp
80101594:	52                   	push   %edx
80101595:	50                   	push   %eax
80101596:	e8 1b ec ff ff       	call   801001b6 <bread>
8010159b:	83 c4 10             	add    $0x10,%esp
8010159e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a4:	25 ff 0f 00 00       	and    $0xfff,%eax
801015a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015af:	99                   	cltd   
801015b0:	c1 ea 1d             	shr    $0x1d,%edx
801015b3:	01 d0                	add    %edx,%eax
801015b5:	83 e0 07             	and    $0x7,%eax
801015b8:	29 d0                	sub    %edx,%eax
801015ba:	ba 01 00 00 00       	mov    $0x1,%edx
801015bf:	89 c1                	mov    %eax,%ecx
801015c1:	d3 e2                	shl    %cl,%edx
801015c3:	89 d0                	mov    %edx,%eax
801015c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015cb:	8d 50 07             	lea    0x7(%eax),%edx
801015ce:	85 c0                	test   %eax,%eax
801015d0:	0f 48 c2             	cmovs  %edx,%eax
801015d3:	c1 f8 03             	sar    $0x3,%eax
801015d6:	89 c2                	mov    %eax,%edx
801015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015db:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015e0:	0f b6 c0             	movzbl %al,%eax
801015e3:	23 45 ec             	and    -0x14(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	75 0d                	jne    801015f7 <bfree+0x91>
    panic("freeing free block");
801015ea:	83 ec 0c             	sub    $0xc,%esp
801015ed:	68 de 8a 10 80       	push   $0x80108ade
801015f2:	e8 6f ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	8d 50 07             	lea    0x7(%eax),%edx
801015fd:	85 c0                	test   %eax,%eax
801015ff:	0f 48 c2             	cmovs  %edx,%eax
80101602:	c1 f8 03             	sar    $0x3,%eax
80101605:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101608:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010160d:	89 d1                	mov    %edx,%ecx
8010160f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101612:	f7 d2                	not    %edx
80101614:	21 ca                	and    %ecx,%edx
80101616:	89 d1                	mov    %edx,%ecx
80101618:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010161b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010161f:	83 ec 0c             	sub    $0xc,%esp
80101622:	ff 75 f4             	pushl  -0xc(%ebp)
80101625:	e8 5b 21 00 00       	call   80103785 <log_write>
8010162a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	ff 75 f4             	pushl  -0xc(%ebp)
80101633:	e8 f6 eb ff ff       	call   8010022e <brelse>
80101638:	83 c4 10             	add    $0x10,%esp
}
8010163b:	90                   	nop
8010163c:	c9                   	leave  
8010163d:	c3                   	ret    

8010163e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010163e:	55                   	push   %ebp
8010163f:	89 e5                	mov    %esp,%ebp
80101641:	57                   	push   %edi
80101642:	56                   	push   %esi
80101643:	53                   	push   %ebx
80101644:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101647:	83 ec 08             	sub    $0x8,%esp
8010164a:	68 f1 8a 10 80       	push   $0x80108af1
8010164f:	68 60 22 11 80       	push   $0x80112260
80101654:	e8 23 3d 00 00       	call   8010537c <initlock>
80101659:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010165c:	83 ec 08             	sub    $0x8,%esp
8010165f:	68 40 22 11 80       	push   $0x80112240
80101664:	ff 75 08             	pushl  0x8(%ebp)
80101667:	e8 18 fd ff ff       	call   80101384 <readsb>
8010166c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010166f:	a1 58 22 11 80       	mov    0x80112258,%eax
80101674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101677:	8b 3d 54 22 11 80    	mov    0x80112254,%edi
8010167d:	8b 35 50 22 11 80    	mov    0x80112250,%esi
80101683:	8b 1d 4c 22 11 80    	mov    0x8011224c,%ebx
80101689:	8b 0d 48 22 11 80    	mov    0x80112248,%ecx
8010168f:	8b 15 44 22 11 80    	mov    0x80112244,%edx
80101695:	a1 40 22 11 80       	mov    0x80112240,%eax
8010169a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010169d:	57                   	push   %edi
8010169e:	56                   	push   %esi
8010169f:	53                   	push   %ebx
801016a0:	51                   	push   %ecx
801016a1:	52                   	push   %edx
801016a2:	50                   	push   %eax
801016a3:	68 f8 8a 10 80       	push   $0x80108af8
801016a8:	e8 19 ed ff ff       	call   801003c6 <cprintf>
801016ad:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016b0:	90                   	nop
801016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016b4:	5b                   	pop    %ebx
801016b5:	5e                   	pop    %esi
801016b6:	5f                   	pop    %edi
801016b7:	5d                   	pop    %ebp
801016b8:	c3                   	ret    

801016b9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016b9:	55                   	push   %ebp
801016ba:	89 e5                	mov    %esp,%ebp
801016bc:	83 ec 28             	sub    $0x28,%esp
801016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801016c2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016c6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016cd:	e9 9e 00 00 00       	jmp    80101770 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016d5:	c1 e8 03             	shr    $0x3,%eax
801016d8:	89 c2                	mov    %eax,%edx
801016da:	a1 54 22 11 80       	mov    0x80112254,%eax
801016df:	01 d0                	add    %edx,%eax
801016e1:	83 ec 08             	sub    $0x8,%esp
801016e4:	50                   	push   %eax
801016e5:	ff 75 08             	pushl  0x8(%ebp)
801016e8:	e8 c9 ea ff ff       	call   801001b6 <bread>
801016ed:	83 c4 10             	add    $0x10,%esp
801016f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f6:	8d 50 18             	lea    0x18(%eax),%edx
801016f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016fc:	83 e0 07             	and    $0x7,%eax
801016ff:	c1 e0 06             	shl    $0x6,%eax
80101702:	01 d0                	add    %edx,%eax
80101704:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101707:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170a:	0f b7 00             	movzwl (%eax),%eax
8010170d:	66 85 c0             	test   %ax,%ax
80101710:	75 4c                	jne    8010175e <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101712:	83 ec 04             	sub    $0x4,%esp
80101715:	6a 40                	push   $0x40
80101717:	6a 00                	push   $0x0
80101719:	ff 75 ec             	pushl  -0x14(%ebp)
8010171c:	e8 e0 3e 00 00       	call   80105601 <memset>
80101721:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101724:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101727:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010172b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010172e:	83 ec 0c             	sub    $0xc,%esp
80101731:	ff 75 f0             	pushl  -0x10(%ebp)
80101734:	e8 4c 20 00 00       	call   80103785 <log_write>
80101739:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010173c:	83 ec 0c             	sub    $0xc,%esp
8010173f:	ff 75 f0             	pushl  -0x10(%ebp)
80101742:	e8 e7 ea ff ff       	call   8010022e <brelse>
80101747:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010174a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010174d:	83 ec 08             	sub    $0x8,%esp
80101750:	50                   	push   %eax
80101751:	ff 75 08             	pushl  0x8(%ebp)
80101754:	e8 f8 00 00 00       	call   80101851 <iget>
80101759:	83 c4 10             	add    $0x10,%esp
8010175c:	eb 30                	jmp    8010178e <ialloc+0xd5>
    }
    brelse(bp);
8010175e:	83 ec 0c             	sub    $0xc,%esp
80101761:	ff 75 f0             	pushl  -0x10(%ebp)
80101764:	e8 c5 ea ff ff       	call   8010022e <brelse>
80101769:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010176c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101770:	8b 15 48 22 11 80    	mov    0x80112248,%edx
80101776:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101779:	39 c2                	cmp    %eax,%edx
8010177b:	0f 87 51 ff ff ff    	ja     801016d2 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101781:	83 ec 0c             	sub    $0xc,%esp
80101784:	68 4b 8b 10 80       	push   $0x80108b4b
80101789:	e8 d8 ed ff ff       	call   80100566 <panic>
}
8010178e:	c9                   	leave  
8010178f:	c3                   	ret    

80101790 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101796:	8b 45 08             	mov    0x8(%ebp),%eax
80101799:	8b 40 04             	mov    0x4(%eax),%eax
8010179c:	c1 e8 03             	shr    $0x3,%eax
8010179f:	89 c2                	mov    %eax,%edx
801017a1:	a1 54 22 11 80       	mov    0x80112254,%eax
801017a6:	01 c2                	add    %eax,%edx
801017a8:	8b 45 08             	mov    0x8(%ebp),%eax
801017ab:	8b 00                	mov    (%eax),%eax
801017ad:	83 ec 08             	sub    $0x8,%esp
801017b0:	52                   	push   %edx
801017b1:	50                   	push   %eax
801017b2:	e8 ff e9 ff ff       	call   801001b6 <bread>
801017b7:	83 c4 10             	add    $0x10,%esp
801017ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017c0:	8d 50 18             	lea    0x18(%eax),%edx
801017c3:	8b 45 08             	mov    0x8(%ebp),%eax
801017c6:	8b 40 04             	mov    0x4(%eax),%eax
801017c9:	83 e0 07             	and    $0x7,%eax
801017cc:	c1 e0 06             	shl    $0x6,%eax
801017cf:	01 d0                	add    %edx,%eax
801017d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017de:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e1:	8b 45 08             	mov    0x8(%ebp),%eax
801017e4:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017eb:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017ef:	8b 45 08             	mov    0x8(%ebp),%eax
801017f2:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101800:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101804:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101807:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010180b:	8b 45 08             	mov    0x8(%ebp),%eax
8010180e:	8b 50 18             	mov    0x18(%eax),%edx
80101811:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101814:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101817:	8b 45 08             	mov    0x8(%ebp),%eax
8010181a:	8d 50 1c             	lea    0x1c(%eax),%edx
8010181d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101820:	83 c0 0c             	add    $0xc,%eax
80101823:	83 ec 04             	sub    $0x4,%esp
80101826:	6a 34                	push   $0x34
80101828:	52                   	push   %edx
80101829:	50                   	push   %eax
8010182a:	e8 91 3e 00 00       	call   801056c0 <memmove>
8010182f:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101832:	83 ec 0c             	sub    $0xc,%esp
80101835:	ff 75 f4             	pushl  -0xc(%ebp)
80101838:	e8 48 1f 00 00       	call   80103785 <log_write>
8010183d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101840:	83 ec 0c             	sub    $0xc,%esp
80101843:	ff 75 f4             	pushl  -0xc(%ebp)
80101846:	e8 e3 e9 ff ff       	call   8010022e <brelse>
8010184b:	83 c4 10             	add    $0x10,%esp
}
8010184e:	90                   	nop
8010184f:	c9                   	leave  
80101850:	c3                   	ret    

80101851 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101851:	55                   	push   %ebp
80101852:	89 e5                	mov    %esp,%ebp
80101854:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101857:	83 ec 0c             	sub    $0xc,%esp
8010185a:	68 60 22 11 80       	push   $0x80112260
8010185f:	e8 3a 3b 00 00       	call   8010539e <acquire>
80101864:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101867:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010186e:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101875:	eb 5d                	jmp    801018d4 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101877:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187a:	8b 40 08             	mov    0x8(%eax),%eax
8010187d:	85 c0                	test   %eax,%eax
8010187f:	7e 39                	jle    801018ba <iget+0x69>
80101881:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101884:	8b 00                	mov    (%eax),%eax
80101886:	3b 45 08             	cmp    0x8(%ebp),%eax
80101889:	75 2f                	jne    801018ba <iget+0x69>
8010188b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010188e:	8b 40 04             	mov    0x4(%eax),%eax
80101891:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101894:	75 24                	jne    801018ba <iget+0x69>
      ip->ref++;
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 08             	mov    0x8(%eax),%eax
8010189c:	8d 50 01             	lea    0x1(%eax),%edx
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018a5:	83 ec 0c             	sub    $0xc,%esp
801018a8:	68 60 22 11 80       	push   $0x80112260
801018ad:	e8 53 3b 00 00       	call   80105405 <release>
801018b2:	83 c4 10             	add    $0x10,%esp
      return ip;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	eb 74                	jmp    8010192e <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018ba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018be:	75 10                	jne    801018d0 <iget+0x7f>
801018c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c3:	8b 40 08             	mov    0x8(%eax),%eax
801018c6:	85 c0                	test   %eax,%eax
801018c8:	75 06                	jne    801018d0 <iget+0x7f>
      empty = ip;
801018ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018cd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018d0:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018d4:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
801018db:	72 9a                	jb     80101877 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018dd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018e1:	75 0d                	jne    801018f0 <iget+0x9f>
    panic("iget: no inodes");
801018e3:	83 ec 0c             	sub    $0xc,%esp
801018e6:	68 5d 8b 10 80       	push   $0x80108b5d
801018eb:	e8 76 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	8b 55 08             	mov    0x8(%ebp),%edx
801018fc:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101901:	8b 55 0c             	mov    0xc(%ebp),%edx
80101904:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101911:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101914:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010191b:	83 ec 0c             	sub    $0xc,%esp
8010191e:	68 60 22 11 80       	push   $0x80112260
80101923:	e8 dd 3a 00 00       	call   80105405 <release>
80101928:	83 c4 10             	add    $0x10,%esp

  return ip;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010192e:	c9                   	leave  
8010192f:	c3                   	ret    

80101930 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101930:	55                   	push   %ebp
80101931:	89 e5                	mov    %esp,%ebp
80101933:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101936:	83 ec 0c             	sub    $0xc,%esp
80101939:	68 60 22 11 80       	push   $0x80112260
8010193e:	e8 5b 3a 00 00       	call   8010539e <acquire>
80101943:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101946:	8b 45 08             	mov    0x8(%ebp),%eax
80101949:	8b 40 08             	mov    0x8(%eax),%eax
8010194c:	8d 50 01             	lea    0x1(%eax),%edx
8010194f:	8b 45 08             	mov    0x8(%ebp),%eax
80101952:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101955:	83 ec 0c             	sub    $0xc,%esp
80101958:	68 60 22 11 80       	push   $0x80112260
8010195d:	e8 a3 3a 00 00       	call   80105405 <release>
80101962:	83 c4 10             	add    $0x10,%esp
  return ip;
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101968:	c9                   	leave  
80101969:	c3                   	ret    

8010196a <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010196a:	55                   	push   %ebp
8010196b:	89 e5                	mov    %esp,%ebp
8010196d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101970:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101974:	74 0a                	je     80101980 <ilock+0x16>
80101976:	8b 45 08             	mov    0x8(%ebp),%eax
80101979:	8b 40 08             	mov    0x8(%eax),%eax
8010197c:	85 c0                	test   %eax,%eax
8010197e:	7f 0d                	jg     8010198d <ilock+0x23>
    panic("ilock");
80101980:	83 ec 0c             	sub    $0xc,%esp
80101983:	68 6d 8b 10 80       	push   $0x80108b6d
80101988:	e8 d9 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010198d:	83 ec 0c             	sub    $0xc,%esp
80101990:	68 60 22 11 80       	push   $0x80112260
80101995:	e8 04 3a 00 00       	call   8010539e <acquire>
8010199a:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010199d:	eb 13                	jmp    801019b2 <ilock+0x48>
    sleep(ip, &icache.lock);
8010199f:	83 ec 08             	sub    $0x8,%esp
801019a2:	68 60 22 11 80       	push   $0x80112260
801019a7:	ff 75 08             	pushl  0x8(%ebp)
801019aa:	e8 4e 34 00 00       	call   80104dfd <sleep>
801019af:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
801019b2:	8b 45 08             	mov    0x8(%ebp),%eax
801019b5:	8b 40 0c             	mov    0xc(%eax),%eax
801019b8:	83 e0 01             	and    $0x1,%eax
801019bb:	85 c0                	test   %eax,%eax
801019bd:	75 e0                	jne    8010199f <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019bf:	8b 45 08             	mov    0x8(%ebp),%eax
801019c2:	8b 40 0c             	mov    0xc(%eax),%eax
801019c5:	83 c8 01             	or     $0x1,%eax
801019c8:	89 c2                	mov    %eax,%edx
801019ca:	8b 45 08             	mov    0x8(%ebp),%eax
801019cd:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019d0:	83 ec 0c             	sub    $0xc,%esp
801019d3:	68 60 22 11 80       	push   $0x80112260
801019d8:	e8 28 3a 00 00       	call   80105405 <release>
801019dd:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019e0:	8b 45 08             	mov    0x8(%ebp),%eax
801019e3:	8b 40 0c             	mov    0xc(%eax),%eax
801019e6:	83 e0 02             	and    $0x2,%eax
801019e9:	85 c0                	test   %eax,%eax
801019eb:	0f 85 d4 00 00 00    	jne    80101ac5 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019f1:	8b 45 08             	mov    0x8(%ebp),%eax
801019f4:	8b 40 04             	mov    0x4(%eax),%eax
801019f7:	c1 e8 03             	shr    $0x3,%eax
801019fa:	89 c2                	mov    %eax,%edx
801019fc:	a1 54 22 11 80       	mov    0x80112254,%eax
80101a01:	01 c2                	add    %eax,%edx
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 00                	mov    (%eax),%eax
80101a08:	83 ec 08             	sub    $0x8,%esp
80101a0b:	52                   	push   %edx
80101a0c:	50                   	push   %eax
80101a0d:	e8 a4 e7 ff ff       	call   801001b6 <bread>
80101a12:	83 c4 10             	add    $0x10,%esp
80101a15:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1b:	8d 50 18             	lea    0x18(%eax),%edx
80101a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a21:	8b 40 04             	mov    0x4(%eax),%eax
80101a24:	83 e0 07             	and    $0x7,%eax
80101a27:	c1 e0 06             	shl    $0x6,%eax
80101a2a:	01 d0                	add    %edx,%eax
80101a2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a32:	0f b7 10             	movzwl (%eax),%edx
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a3f:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a43:	8b 45 08             	mov    0x8(%ebp),%eax
80101a46:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4d:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a58:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5b:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a62:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a69:	8b 50 08             	mov    0x8(%eax),%edx
80101a6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6f:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a75:	8d 50 0c             	lea    0xc(%eax),%edx
80101a78:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7b:	83 c0 1c             	add    $0x1c,%eax
80101a7e:	83 ec 04             	sub    $0x4,%esp
80101a81:	6a 34                	push   $0x34
80101a83:	52                   	push   %edx
80101a84:	50                   	push   %eax
80101a85:	e8 36 3c 00 00       	call   801056c0 <memmove>
80101a8a:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a8d:	83 ec 0c             	sub    $0xc,%esp
80101a90:	ff 75 f4             	pushl  -0xc(%ebp)
80101a93:	e8 96 e7 ff ff       	call   8010022e <brelse>
80101a98:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9e:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa1:	83 c8 02             	or     $0x2,%eax
80101aa4:	89 c2                	mov    %eax,%edx
80101aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa9:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101aac:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ab3:	66 85 c0             	test   %ax,%ax
80101ab6:	75 0d                	jne    80101ac5 <ilock+0x15b>
      panic("ilock: no type");
80101ab8:	83 ec 0c             	sub    $0xc,%esp
80101abb:	68 73 8b 10 80       	push   $0x80108b73
80101ac0:	e8 a1 ea ff ff       	call   80100566 <panic>
  }
}
80101ac5:	90                   	nop
80101ac6:	c9                   	leave  
80101ac7:	c3                   	ret    

80101ac8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ac8:	55                   	push   %ebp
80101ac9:	89 e5                	mov    %esp,%ebp
80101acb:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ace:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ad2:	74 17                	je     80101aeb <iunlock+0x23>
80101ad4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad7:	8b 40 0c             	mov    0xc(%eax),%eax
80101ada:	83 e0 01             	and    $0x1,%eax
80101add:	85 c0                	test   %eax,%eax
80101adf:	74 0a                	je     80101aeb <iunlock+0x23>
80101ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae4:	8b 40 08             	mov    0x8(%eax),%eax
80101ae7:	85 c0                	test   %eax,%eax
80101ae9:	7f 0d                	jg     80101af8 <iunlock+0x30>
    panic("iunlock");
80101aeb:	83 ec 0c             	sub    $0xc,%esp
80101aee:	68 82 8b 10 80       	push   $0x80108b82
80101af3:	e8 6e ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101af8:	83 ec 0c             	sub    $0xc,%esp
80101afb:	68 60 22 11 80       	push   $0x80112260
80101b00:	e8 99 38 00 00       	call   8010539e <acquire>
80101b05:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b08:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0b:	8b 40 0c             	mov    0xc(%eax),%eax
80101b0e:	83 e0 fe             	and    $0xfffffffe,%eax
80101b11:	89 c2                	mov    %eax,%edx
80101b13:	8b 45 08             	mov    0x8(%ebp),%eax
80101b16:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b19:	83 ec 0c             	sub    $0xc,%esp
80101b1c:	ff 75 08             	pushl  0x8(%ebp)
80101b1f:	e8 c0 33 00 00       	call   80104ee4 <wakeup>
80101b24:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b27:	83 ec 0c             	sub    $0xc,%esp
80101b2a:	68 60 22 11 80       	push   $0x80112260
80101b2f:	e8 d1 38 00 00       	call   80105405 <release>
80101b34:	83 c4 10             	add    $0x10,%esp
}
80101b37:	90                   	nop
80101b38:	c9                   	leave  
80101b39:	c3                   	ret    

80101b3a <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b3a:	55                   	push   %ebp
80101b3b:	89 e5                	mov    %esp,%ebp
80101b3d:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b40:	83 ec 0c             	sub    $0xc,%esp
80101b43:	68 60 22 11 80       	push   $0x80112260
80101b48:	e8 51 38 00 00       	call   8010539e <acquire>
80101b4d:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b50:	8b 45 08             	mov    0x8(%ebp),%eax
80101b53:	8b 40 08             	mov    0x8(%eax),%eax
80101b56:	83 f8 01             	cmp    $0x1,%eax
80101b59:	0f 85 a9 00 00 00    	jne    80101c08 <iput+0xce>
80101b5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b62:	8b 40 0c             	mov    0xc(%eax),%eax
80101b65:	83 e0 02             	and    $0x2,%eax
80101b68:	85 c0                	test   %eax,%eax
80101b6a:	0f 84 98 00 00 00    	je     80101c08 <iput+0xce>
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b77:	66 85 c0             	test   %ax,%ax
80101b7a:	0f 85 88 00 00 00    	jne    80101c08 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b80:	8b 45 08             	mov    0x8(%ebp),%eax
80101b83:	8b 40 0c             	mov    0xc(%eax),%eax
80101b86:	83 e0 01             	and    $0x1,%eax
80101b89:	85 c0                	test   %eax,%eax
80101b8b:	74 0d                	je     80101b9a <iput+0x60>
      panic("iput busy");
80101b8d:	83 ec 0c             	sub    $0xc,%esp
80101b90:	68 8a 8b 10 80       	push   $0x80108b8a
80101b95:	e8 cc e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b9a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b9d:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba0:	83 c8 01             	or     $0x1,%eax
80101ba3:	89 c2                	mov    %eax,%edx
80101ba5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba8:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bab:	83 ec 0c             	sub    $0xc,%esp
80101bae:	68 60 22 11 80       	push   $0x80112260
80101bb3:	e8 4d 38 00 00       	call   80105405 <release>
80101bb8:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bbb:	83 ec 0c             	sub    $0xc,%esp
80101bbe:	ff 75 08             	pushl  0x8(%ebp)
80101bc1:	e8 a8 01 00 00       	call   80101d6e <itrunc>
80101bc6:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bcc:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bd2:	83 ec 0c             	sub    $0xc,%esp
80101bd5:	ff 75 08             	pushl  0x8(%ebp)
80101bd8:	e8 b3 fb ff ff       	call   80101790 <iupdate>
80101bdd:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101be0:	83 ec 0c             	sub    $0xc,%esp
80101be3:	68 60 22 11 80       	push   $0x80112260
80101be8:	e8 b1 37 00 00       	call   8010539e <acquire>
80101bed:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bfa:	83 ec 0c             	sub    $0xc,%esp
80101bfd:	ff 75 08             	pushl  0x8(%ebp)
80101c00:	e8 df 32 00 00       	call   80104ee4 <wakeup>
80101c05:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	68 60 22 11 80       	push   $0x80112260
80101c1f:	e8 e1 37 00 00       	call   80105405 <release>
80101c24:	83 c4 10             	add    $0x10,%esp
}
80101c27:	90                   	nop
80101c28:	c9                   	leave  
80101c29:	c3                   	ret    

80101c2a <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c2a:	55                   	push   %ebp
80101c2b:	89 e5                	mov    %esp,%ebp
80101c2d:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c30:	83 ec 0c             	sub    $0xc,%esp
80101c33:	ff 75 08             	pushl  0x8(%ebp)
80101c36:	e8 8d fe ff ff       	call   80101ac8 <iunlock>
80101c3b:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c3e:	83 ec 0c             	sub    $0xc,%esp
80101c41:	ff 75 08             	pushl  0x8(%ebp)
80101c44:	e8 f1 fe ff ff       	call   80101b3a <iput>
80101c49:	83 c4 10             	add    $0x10,%esp
}
80101c4c:	90                   	nop
80101c4d:	c9                   	leave  
80101c4e:	c3                   	ret    

80101c4f <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c4f:	55                   	push   %ebp
80101c50:	89 e5                	mov    %esp,%ebp
80101c52:	53                   	push   %ebx
80101c53:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c56:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c5a:	77 42                	ja     80101c9e <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c62:	83 c2 04             	add    $0x4,%edx
80101c65:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c69:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c70:	75 24                	jne    80101c96 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c72:	8b 45 08             	mov    0x8(%ebp),%eax
80101c75:	8b 00                	mov    (%eax),%eax
80101c77:	83 ec 0c             	sub    $0xc,%esp
80101c7a:	50                   	push   %eax
80101c7b:	e8 9a f7 ff ff       	call   8010141a <balloc>
80101c80:	83 c4 10             	add    $0x10,%esp
80101c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c86:	8b 45 08             	mov    0x8(%ebp),%eax
80101c89:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c8c:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c92:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c99:	e9 cb 00 00 00       	jmp    80101d69 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c9e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101ca2:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101ca6:	0f 87 b0 00 00 00    	ja     80101d5c <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cac:	8b 45 08             	mov    0x8(%ebp),%eax
80101caf:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb9:	75 1d                	jne    80101cd8 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	8b 00                	mov    (%eax),%eax
80101cc0:	83 ec 0c             	sub    $0xc,%esp
80101cc3:	50                   	push   %eax
80101cc4:	e8 51 f7 ff ff       	call   8010141a <balloc>
80101cc9:	83 c4 10             	add    $0x10,%esp
80101ccc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ccf:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd5:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdb:	8b 00                	mov    (%eax),%eax
80101cdd:	83 ec 08             	sub    $0x8,%esp
80101ce0:	ff 75 f4             	pushl  -0xc(%ebp)
80101ce3:	50                   	push   %eax
80101ce4:	e8 cd e4 ff ff       	call   801001b6 <bread>
80101ce9:	83 c4 10             	add    $0x10,%esp
80101cec:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf2:	83 c0 18             	add    $0x18,%eax
80101cf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d05:	01 d0                	add    %edx,%eax
80101d07:	8b 00                	mov    (%eax),%eax
80101d09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d10:	75 37                	jne    80101d49 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101d12:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d1f:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d22:	8b 45 08             	mov    0x8(%ebp),%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	83 ec 0c             	sub    $0xc,%esp
80101d2a:	50                   	push   %eax
80101d2b:	e8 ea f6 ff ff       	call   8010141a <balloc>
80101d30:	83 c4 10             	add    $0x10,%esp
80101d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d39:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d3b:	83 ec 0c             	sub    $0xc,%esp
80101d3e:	ff 75 f0             	pushl  -0x10(%ebp)
80101d41:	e8 3f 1a 00 00       	call   80103785 <log_write>
80101d46:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d49:	83 ec 0c             	sub    $0xc,%esp
80101d4c:	ff 75 f0             	pushl  -0x10(%ebp)
80101d4f:	e8 da e4 ff ff       	call   8010022e <brelse>
80101d54:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d5a:	eb 0d                	jmp    80101d69 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d5c:	83 ec 0c             	sub    $0xc,%esp
80101d5f:	68 94 8b 10 80       	push   $0x80108b94
80101d64:	e8 fd e7 ff ff       	call   80100566 <panic>
}
80101d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d6c:	c9                   	leave  
80101d6d:	c3                   	ret    

80101d6e <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d6e:	55                   	push   %ebp
80101d6f:	89 e5                	mov    %esp,%ebp
80101d71:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d7b:	eb 45                	jmp    80101dc2 <itrunc+0x54>
    if(ip->addrs[i]){
80101d7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	83 c2 04             	add    $0x4,%edx
80101d86:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d8a:	85 c0                	test   %eax,%eax
80101d8c:	74 30                	je     80101dbe <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d94:	83 c2 04             	add    $0x4,%edx
80101d97:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d9b:	8b 55 08             	mov    0x8(%ebp),%edx
80101d9e:	8b 12                	mov    (%edx),%edx
80101da0:	83 ec 08             	sub    $0x8,%esp
80101da3:	50                   	push   %eax
80101da4:	52                   	push   %edx
80101da5:	e8 bc f7 ff ff       	call   80101566 <bfree>
80101daa:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101db3:	83 c2 04             	add    $0x4,%edx
80101db6:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dbd:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dbe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dc2:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc6:	7e b5                	jle    80101d7d <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101dce:	85 c0                	test   %eax,%eax
80101dd0:	0f 84 a1 00 00 00    	je     80101e77 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd9:	8b 50 4c             	mov    0x4c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 cb e3 ff ff       	call   801001b6 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 18             	add    $0x18,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd1>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 2e f7 ff ff       	call   80101566 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	pushl  -0x14(%ebp)
80101e4d:	e8 dc e3 ff ff       	call   8010022e <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e5b:	8b 55 08             	mov    0x8(%ebp),%edx
80101e5e:	8b 12                	mov    (%edx),%edx
80101e60:	83 ec 08             	sub    $0x8,%esp
80101e63:	50                   	push   %eax
80101e64:	52                   	push   %edx
80101e65:	e8 fc f6 ff ff       	call   80101566 <bfree>
80101e6a:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e70:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e81:	83 ec 0c             	sub    $0xc,%esp
80101e84:	ff 75 08             	pushl  0x8(%ebp)
80101e87:	e8 04 f9 ff ff       	call   80101790 <iupdate>
80101e8c:	83 c4 10             	add    $0x10,%esp
}
80101e8f:	90                   	nop
80101e90:	c9                   	leave  
80101e91:	c3                   	ret    

80101e92 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e92:	55                   	push   %ebp
80101e93:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 00                	mov    (%eax),%eax
80101e9a:	89 c2                	mov    %eax,%edx
80101e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9f:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea5:	8b 50 04             	mov    0x4(%eax),%edx
80101ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eab:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb8:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebe:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 50 18             	mov    0x18(%eax),%edx
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ed5:	90                   	nop
80101ed6:	5d                   	pop    %ebp
80101ed7:	c3                   	ret    

80101ed8 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ed8:	55                   	push   %ebp
80101ed9:	89 e5                	mov    %esp,%ebp
80101edb:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ede:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ee5:	66 83 f8 03          	cmp    $0x3,%ax
80101ee9:	75 5c                	jne    80101f47 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101eeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101eee:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef2:	66 85 c0             	test   %ax,%ax
80101ef5:	78 20                	js     80101f17 <readi+0x3f>
80101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
80101efa:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101efe:	66 83 f8 09          	cmp    $0x9,%ax
80101f02:	7f 13                	jg     80101f17 <readi+0x3f>
80101f04:	8b 45 08             	mov    0x8(%ebp),%eax
80101f07:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0b:	98                   	cwtl   
80101f0c:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101f13:	85 c0                	test   %eax,%eax
80101f15:	75 0a                	jne    80101f21 <readi+0x49>
      return -1;
80101f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f1c:	e9 0c 01 00 00       	jmp    8010202d <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f21:	8b 45 08             	mov    0x8(%ebp),%eax
80101f24:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f28:	98                   	cwtl   
80101f29:	8b 04 c5 e0 21 11 80 	mov    -0x7feede20(,%eax,8),%eax
80101f30:	8b 55 14             	mov    0x14(%ebp),%edx
80101f33:	83 ec 04             	sub    $0x4,%esp
80101f36:	52                   	push   %edx
80101f37:	ff 75 0c             	pushl  0xc(%ebp)
80101f3a:	ff 75 08             	pushl  0x8(%ebp)
80101f3d:	ff d0                	call   *%eax
80101f3f:	83 c4 10             	add    $0x10,%esp
80101f42:	e9 e6 00 00 00       	jmp    8010202d <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	8b 40 18             	mov    0x18(%eax),%eax
80101f4d:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f50:	72 0d                	jb     80101f5f <readi+0x87>
80101f52:	8b 55 10             	mov    0x10(%ebp),%edx
80101f55:	8b 45 14             	mov    0x14(%ebp),%eax
80101f58:	01 d0                	add    %edx,%eax
80101f5a:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f5d:	73 0a                	jae    80101f69 <readi+0x91>
    return -1;
80101f5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f64:	e9 c4 00 00 00       	jmp    8010202d <readi+0x155>
  if(off + n > ip->size)
80101f69:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6c:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6f:	01 c2                	add    %eax,%edx
80101f71:	8b 45 08             	mov    0x8(%ebp),%eax
80101f74:	8b 40 18             	mov    0x18(%eax),%eax
80101f77:	39 c2                	cmp    %eax,%edx
80101f79:	76 0c                	jbe    80101f87 <readi+0xaf>
    n = ip->size - off;
80101f7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7e:	8b 40 18             	mov    0x18(%eax),%eax
80101f81:	2b 45 10             	sub    0x10(%ebp),%eax
80101f84:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f8e:	e9 8b 00 00 00       	jmp    8010201e <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f93:	8b 45 10             	mov    0x10(%ebp),%eax
80101f96:	c1 e8 09             	shr    $0x9,%eax
80101f99:	83 ec 08             	sub    $0x8,%esp
80101f9c:	50                   	push   %eax
80101f9d:	ff 75 08             	pushl  0x8(%ebp)
80101fa0:	e8 aa fc ff ff       	call   80101c4f <bmap>
80101fa5:	83 c4 10             	add    $0x10,%esp
80101fa8:	89 c2                	mov    %eax,%edx
80101faa:	8b 45 08             	mov    0x8(%ebp),%eax
80101fad:	8b 00                	mov    (%eax),%eax
80101faf:	83 ec 08             	sub    $0x8,%esp
80101fb2:	52                   	push   %edx
80101fb3:	50                   	push   %eax
80101fb4:	e8 fd e1 ff ff       	call   801001b6 <bread>
80101fb9:	83 c4 10             	add    $0x10,%esp
80101fbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fbf:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc2:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fc7:	ba 00 02 00 00       	mov    $0x200,%edx
80101fcc:	29 c2                	sub    %eax,%edx
80101fce:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd1:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd4:	39 c2                	cmp    %eax,%edx
80101fd6:	0f 46 c2             	cmovbe %edx,%eax
80101fd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fdf:	8d 50 18             	lea    0x18(%eax),%edx
80101fe2:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe5:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fea:	01 d0                	add    %edx,%eax
80101fec:	83 ec 04             	sub    $0x4,%esp
80101fef:	ff 75 ec             	pushl  -0x14(%ebp)
80101ff2:	50                   	push   %eax
80101ff3:	ff 75 0c             	pushl  0xc(%ebp)
80101ff6:	e8 c5 36 00 00       	call   801056c0 <memmove>
80101ffb:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ffe:	83 ec 0c             	sub    $0xc,%esp
80102001:	ff 75 f0             	pushl  -0x10(%ebp)
80102004:	e8 25 e2 ff ff       	call   8010022e <brelse>
80102009:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102012:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102015:	01 45 10             	add    %eax,0x10(%ebp)
80102018:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201b:	01 45 0c             	add    %eax,0xc(%ebp)
8010201e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102021:	3b 45 14             	cmp    0x14(%ebp),%eax
80102024:	0f 82 69 ff ff ff    	jb     80101f93 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010202a:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010202d:	c9                   	leave  
8010202e:	c3                   	ret    

8010202f <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
8010202f:	55                   	push   %ebp
80102030:	89 e5                	mov    %esp,%ebp
80102032:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102035:	8b 45 08             	mov    0x8(%ebp),%eax
80102038:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010203c:	66 83 f8 03          	cmp    $0x3,%ax
80102040:	75 5c                	jne    8010209e <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102042:	8b 45 08             	mov    0x8(%ebp),%eax
80102045:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102049:	66 85 c0             	test   %ax,%ax
8010204c:	78 20                	js     8010206e <writei+0x3f>
8010204e:	8b 45 08             	mov    0x8(%ebp),%eax
80102051:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102055:	66 83 f8 09          	cmp    $0x9,%ax
80102059:	7f 13                	jg     8010206e <writei+0x3f>
8010205b:	8b 45 08             	mov    0x8(%ebp),%eax
8010205e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102062:	98                   	cwtl   
80102063:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
8010206a:	85 c0                	test   %eax,%eax
8010206c:	75 0a                	jne    80102078 <writei+0x49>
      return -1;
8010206e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102073:	e9 3d 01 00 00       	jmp    801021b5 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102078:	8b 45 08             	mov    0x8(%ebp),%eax
8010207b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207f:	98                   	cwtl   
80102080:	8b 04 c5 e4 21 11 80 	mov    -0x7feede1c(,%eax,8),%eax
80102087:	8b 55 14             	mov    0x14(%ebp),%edx
8010208a:	83 ec 04             	sub    $0x4,%esp
8010208d:	52                   	push   %edx
8010208e:	ff 75 0c             	pushl  0xc(%ebp)
80102091:	ff 75 08             	pushl  0x8(%ebp)
80102094:	ff d0                	call   *%eax
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	e9 17 01 00 00       	jmp    801021b5 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
8010209e:	8b 45 08             	mov    0x8(%ebp),%eax
801020a1:	8b 40 18             	mov    0x18(%eax),%eax
801020a4:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a7:	72 0d                	jb     801020b6 <writei+0x87>
801020a9:	8b 55 10             	mov    0x10(%ebp),%edx
801020ac:	8b 45 14             	mov    0x14(%ebp),%eax
801020af:	01 d0                	add    %edx,%eax
801020b1:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b4:	73 0a                	jae    801020c0 <writei+0x91>
    return -1;
801020b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bb:	e9 f5 00 00 00       	jmp    801021b5 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020c0:	8b 55 10             	mov    0x10(%ebp),%edx
801020c3:	8b 45 14             	mov    0x14(%ebp),%eax
801020c6:	01 d0                	add    %edx,%eax
801020c8:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020cd:	76 0a                	jbe    801020d9 <writei+0xaa>
    return -1;
801020cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d4:	e9 dc 00 00 00       	jmp    801021b5 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e0:	e9 99 00 00 00       	jmp    8010217e <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e5:	8b 45 10             	mov    0x10(%ebp),%eax
801020e8:	c1 e8 09             	shr    $0x9,%eax
801020eb:	83 ec 08             	sub    $0x8,%esp
801020ee:	50                   	push   %eax
801020ef:	ff 75 08             	pushl  0x8(%ebp)
801020f2:	e8 58 fb ff ff       	call   80101c4f <bmap>
801020f7:	83 c4 10             	add    $0x10,%esp
801020fa:	89 c2                	mov    %eax,%edx
801020fc:	8b 45 08             	mov    0x8(%ebp),%eax
801020ff:	8b 00                	mov    (%eax),%eax
80102101:	83 ec 08             	sub    $0x8,%esp
80102104:	52                   	push   %edx
80102105:	50                   	push   %eax
80102106:	e8 ab e0 ff ff       	call   801001b6 <bread>
8010210b:	83 c4 10             	add    $0x10,%esp
8010210e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102111:	8b 45 10             	mov    0x10(%ebp),%eax
80102114:	25 ff 01 00 00       	and    $0x1ff,%eax
80102119:	ba 00 02 00 00       	mov    $0x200,%edx
8010211e:	29 c2                	sub    %eax,%edx
80102120:	8b 45 14             	mov    0x14(%ebp),%eax
80102123:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102126:	39 c2                	cmp    %eax,%edx
80102128:	0f 46 c2             	cmovbe %edx,%eax
8010212b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
8010212e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102131:	8d 50 18             	lea    0x18(%eax),%edx
80102134:	8b 45 10             	mov    0x10(%ebp),%eax
80102137:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213c:	01 d0                	add    %edx,%eax
8010213e:	83 ec 04             	sub    $0x4,%esp
80102141:	ff 75 ec             	pushl  -0x14(%ebp)
80102144:	ff 75 0c             	pushl  0xc(%ebp)
80102147:	50                   	push   %eax
80102148:	e8 73 35 00 00       	call   801056c0 <memmove>
8010214d:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102150:	83 ec 0c             	sub    $0xc,%esp
80102153:	ff 75 f0             	pushl  -0x10(%ebp)
80102156:	e8 2a 16 00 00       	call   80103785 <log_write>
8010215b:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
8010215e:	83 ec 0c             	sub    $0xc,%esp
80102161:	ff 75 f0             	pushl  -0x10(%ebp)
80102164:	e8 c5 e0 ff ff       	call   8010022e <brelse>
80102169:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216f:	01 45 f4             	add    %eax,-0xc(%ebp)
80102172:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102175:	01 45 10             	add    %eax,0x10(%ebp)
80102178:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217b:	01 45 0c             	add    %eax,0xc(%ebp)
8010217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102181:	3b 45 14             	cmp    0x14(%ebp),%eax
80102184:	0f 82 5b ff ff ff    	jb     801020e5 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010218a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010218e:	74 22                	je     801021b2 <writei+0x183>
80102190:	8b 45 08             	mov    0x8(%ebp),%eax
80102193:	8b 40 18             	mov    0x18(%eax),%eax
80102196:	3b 45 10             	cmp    0x10(%ebp),%eax
80102199:	73 17                	jae    801021b2 <writei+0x183>
    ip->size = off;
8010219b:	8b 45 08             	mov    0x8(%ebp),%eax
8010219e:	8b 55 10             	mov    0x10(%ebp),%edx
801021a1:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021a4:	83 ec 0c             	sub    $0xc,%esp
801021a7:	ff 75 08             	pushl  0x8(%ebp)
801021aa:	e8 e1 f5 ff ff       	call   80101790 <iupdate>
801021af:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b2:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b5:	c9                   	leave  
801021b6:	c3                   	ret    

801021b7 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b7:	55                   	push   %ebp
801021b8:	89 e5                	mov    %esp,%ebp
801021ba:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bd:	83 ec 04             	sub    $0x4,%esp
801021c0:	6a 0e                	push   $0xe
801021c2:	ff 75 0c             	pushl  0xc(%ebp)
801021c5:	ff 75 08             	pushl  0x8(%ebp)
801021c8:	e8 89 35 00 00       	call   80105756 <strncmp>
801021cd:	83 c4 10             	add    $0x10,%esp
}
801021d0:	c9                   	leave  
801021d1:	c3                   	ret    

801021d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d2:	55                   	push   %ebp
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021df:	66 83 f8 01          	cmp    $0x1,%ax
801021e3:	74 0d                	je     801021f2 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e5:	83 ec 0c             	sub    $0xc,%esp
801021e8:	68 a7 8b 10 80       	push   $0x80108ba7
801021ed:	e8 74 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f9:	eb 7b                	jmp    80102276 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fb:	6a 10                	push   $0x10
801021fd:	ff 75 f4             	pushl  -0xc(%ebp)
80102200:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102203:	50                   	push   %eax
80102204:	ff 75 08             	pushl  0x8(%ebp)
80102207:	e8 cc fc ff ff       	call   80101ed8 <readi>
8010220c:	83 c4 10             	add    $0x10,%esp
8010220f:	83 f8 10             	cmp    $0x10,%eax
80102212:	74 0d                	je     80102221 <dirlookup+0x4f>
      panic("dirlink read");
80102214:	83 ec 0c             	sub    $0xc,%esp
80102217:	68 b9 8b 10 80       	push   $0x80108bb9
8010221c:	e8 45 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102221:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102225:	66 85 c0             	test   %ax,%ax
80102228:	74 47                	je     80102271 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222a:	83 ec 08             	sub    $0x8,%esp
8010222d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102230:	83 c0 02             	add    $0x2,%eax
80102233:	50                   	push   %eax
80102234:	ff 75 0c             	pushl  0xc(%ebp)
80102237:	e8 7b ff ff ff       	call   801021b7 <namecmp>
8010223c:	83 c4 10             	add    $0x10,%esp
8010223f:	85 c0                	test   %eax,%eax
80102241:	75 2f                	jne    80102272 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102243:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102247:	74 08                	je     80102251 <dirlookup+0x7f>
        *poff = off;
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010224f:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102251:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102255:	0f b7 c0             	movzwl %ax,%eax
80102258:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 00                	mov    (%eax),%eax
80102260:	83 ec 08             	sub    $0x8,%esp
80102263:	ff 75 f0             	pushl  -0x10(%ebp)
80102266:	50                   	push   %eax
80102267:	e8 e5 f5 ff ff       	call   80101851 <iget>
8010226c:	83 c4 10             	add    $0x10,%esp
8010226f:	eb 19                	jmp    8010228a <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102271:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102272:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102276:	8b 45 08             	mov    0x8(%ebp),%eax
80102279:	8b 40 18             	mov    0x18(%eax),%eax
8010227c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010227f:	0f 87 76 ff ff ff    	ja     801021fb <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102285:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228a:	c9                   	leave  
8010228b:	c3                   	ret    

8010228c <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228c:	55                   	push   %ebp
8010228d:	89 e5                	mov    %esp,%ebp
8010228f:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102292:	83 ec 04             	sub    $0x4,%esp
80102295:	6a 00                	push   $0x0
80102297:	ff 75 0c             	pushl  0xc(%ebp)
8010229a:	ff 75 08             	pushl  0x8(%ebp)
8010229d:	e8 30 ff ff ff       	call   801021d2 <dirlookup>
801022a2:	83 c4 10             	add    $0x10,%esp
801022a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ac:	74 18                	je     801022c6 <dirlink+0x3a>
    iput(ip);
801022ae:	83 ec 0c             	sub    $0xc,%esp
801022b1:	ff 75 f0             	pushl  -0x10(%ebp)
801022b4:	e8 81 f8 ff ff       	call   80101b3a <iput>
801022b9:	83 c4 10             	add    $0x10,%esp
    return -1;
801022bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c1:	e9 9c 00 00 00       	jmp    80102362 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cd:	eb 39                	jmp    80102308 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d2:	6a 10                	push   $0x10
801022d4:	50                   	push   %eax
801022d5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022d8:	50                   	push   %eax
801022d9:	ff 75 08             	pushl  0x8(%ebp)
801022dc:	e8 f7 fb ff ff       	call   80101ed8 <readi>
801022e1:	83 c4 10             	add    $0x10,%esp
801022e4:	83 f8 10             	cmp    $0x10,%eax
801022e7:	74 0d                	je     801022f6 <dirlink+0x6a>
      panic("dirlink read");
801022e9:	83 ec 0c             	sub    $0xc,%esp
801022ec:	68 b9 8b 10 80       	push   $0x80108bb9
801022f1:	e8 70 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fa:	66 85 c0             	test   %ax,%ax
801022fd:	74 18                	je     80102317 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102302:	83 c0 10             	add    $0x10,%eax
80102305:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102308:	8b 45 08             	mov    0x8(%ebp),%eax
8010230b:	8b 50 18             	mov    0x18(%eax),%edx
8010230e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102311:	39 c2                	cmp    %eax,%edx
80102313:	77 ba                	ja     801022cf <dirlink+0x43>
80102315:	eb 01                	jmp    80102318 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
80102317:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
80102318:	83 ec 04             	sub    $0x4,%esp
8010231b:	6a 0e                	push   $0xe
8010231d:	ff 75 0c             	pushl  0xc(%ebp)
80102320:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102323:	83 c0 02             	add    $0x2,%eax
80102326:	50                   	push   %eax
80102327:	e8 80 34 00 00       	call   801057ac <strncpy>
8010232c:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
8010232f:	8b 45 10             	mov    0x10(%ebp),%eax
80102332:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102339:	6a 10                	push   $0x10
8010233b:	50                   	push   %eax
8010233c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010233f:	50                   	push   %eax
80102340:	ff 75 08             	pushl  0x8(%ebp)
80102343:	e8 e7 fc ff ff       	call   8010202f <writei>
80102348:	83 c4 10             	add    $0x10,%esp
8010234b:	83 f8 10             	cmp    $0x10,%eax
8010234e:	74 0d                	je     8010235d <dirlink+0xd1>
    panic("dirlink");
80102350:	83 ec 0c             	sub    $0xc,%esp
80102353:	68 c6 8b 10 80       	push   $0x80108bc6
80102358:	e8 09 e2 ff ff       	call   80100566 <panic>
  
  return 0;
8010235d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102362:	c9                   	leave  
80102363:	c3                   	ret    

80102364 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102364:	55                   	push   %ebp
80102365:	89 e5                	mov    %esp,%ebp
80102367:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236a:	eb 04                	jmp    80102370 <skipelem+0xc>
    path++;
8010236c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	0f b6 00             	movzbl (%eax),%eax
80102376:	3c 2f                	cmp    $0x2f,%al
80102378:	74 f2                	je     8010236c <skipelem+0x8>
    path++;
  if(*path == 0)
8010237a:	8b 45 08             	mov    0x8(%ebp),%eax
8010237d:	0f b6 00             	movzbl (%eax),%eax
80102380:	84 c0                	test   %al,%al
80102382:	75 07                	jne    8010238b <skipelem+0x27>
    return 0;
80102384:	b8 00 00 00 00       	mov    $0x0,%eax
80102389:	eb 7b                	jmp    80102406 <skipelem+0xa2>
  s = path;
8010238b:	8b 45 08             	mov    0x8(%ebp),%eax
8010238e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102391:	eb 04                	jmp    80102397 <skipelem+0x33>
    path++;
80102393:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102397:	8b 45 08             	mov    0x8(%ebp),%eax
8010239a:	0f b6 00             	movzbl (%eax),%eax
8010239d:	3c 2f                	cmp    $0x2f,%al
8010239f:	74 0a                	je     801023ab <skipelem+0x47>
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	0f b6 00             	movzbl (%eax),%eax
801023a7:	84 c0                	test   %al,%al
801023a9:	75 e8                	jne    80102393 <skipelem+0x2f>
    path++;
  len = path - s;
801023ab:	8b 55 08             	mov    0x8(%ebp),%edx
801023ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023b1:	29 c2                	sub    %eax,%edx
801023b3:	89 d0                	mov    %edx,%eax
801023b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b8:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023bc:	7e 15                	jle    801023d3 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023be:	83 ec 04             	sub    $0x4,%esp
801023c1:	6a 0e                	push   $0xe
801023c3:	ff 75 f4             	pushl  -0xc(%ebp)
801023c6:	ff 75 0c             	pushl  0xc(%ebp)
801023c9:	e8 f2 32 00 00       	call   801056c0 <memmove>
801023ce:	83 c4 10             	add    $0x10,%esp
801023d1:	eb 26                	jmp    801023f9 <skipelem+0x95>
  else {
    memmove(name, s, len);
801023d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d6:	83 ec 04             	sub    $0x4,%esp
801023d9:	50                   	push   %eax
801023da:	ff 75 f4             	pushl  -0xc(%ebp)
801023dd:	ff 75 0c             	pushl  0xc(%ebp)
801023e0:	e8 db 32 00 00       	call   801056c0 <memmove>
801023e5:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ee:	01 d0                	add    %edx,%eax
801023f0:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f3:	eb 04                	jmp    801023f9 <skipelem+0x95>
    path++;
801023f5:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023f9:	8b 45 08             	mov    0x8(%ebp),%eax
801023fc:	0f b6 00             	movzbl (%eax),%eax
801023ff:	3c 2f                	cmp    $0x2f,%al
80102401:	74 f2                	je     801023f5 <skipelem+0x91>
    path++;
  return path;
80102403:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102406:	c9                   	leave  
80102407:	c3                   	ret    

80102408 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102408:	55                   	push   %ebp
80102409:	89 e5                	mov    %esp,%ebp
8010240b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240e:	8b 45 08             	mov    0x8(%ebp),%eax
80102411:	0f b6 00             	movzbl (%eax),%eax
80102414:	3c 2f                	cmp    $0x2f,%al
80102416:	75 17                	jne    8010242f <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102418:	83 ec 08             	sub    $0x8,%esp
8010241b:	6a 01                	push   $0x1
8010241d:	6a 01                	push   $0x1
8010241f:	e8 2d f4 ff ff       	call   80101851 <iget>
80102424:	83 c4 10             	add    $0x10,%esp
80102427:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010242a:	e9 bb 00 00 00       	jmp    801024ea <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010242f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102435:	8b 40 68             	mov    0x68(%eax),%eax
80102438:	83 ec 0c             	sub    $0xc,%esp
8010243b:	50                   	push   %eax
8010243c:	e8 ef f4 ff ff       	call   80101930 <idup>
80102441:	83 c4 10             	add    $0x10,%esp
80102444:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102447:	e9 9e 00 00 00       	jmp    801024ea <namex+0xe2>
    ilock(ip);
8010244c:	83 ec 0c             	sub    $0xc,%esp
8010244f:	ff 75 f4             	pushl  -0xc(%ebp)
80102452:	e8 13 f5 ff ff       	call   8010196a <ilock>
80102457:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010245a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102461:	66 83 f8 01          	cmp    $0x1,%ax
80102465:	74 18                	je     8010247f <namex+0x77>
      iunlockput(ip);
80102467:	83 ec 0c             	sub    $0xc,%esp
8010246a:	ff 75 f4             	pushl  -0xc(%ebp)
8010246d:	e8 b8 f7 ff ff       	call   80101c2a <iunlockput>
80102472:	83 c4 10             	add    $0x10,%esp
      return 0;
80102475:	b8 00 00 00 00       	mov    $0x0,%eax
8010247a:	e9 a7 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010247f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102483:	74 20                	je     801024a5 <namex+0x9d>
80102485:	8b 45 08             	mov    0x8(%ebp),%eax
80102488:	0f b6 00             	movzbl (%eax),%eax
8010248b:	84 c0                	test   %al,%al
8010248d:	75 16                	jne    801024a5 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010248f:	83 ec 0c             	sub    $0xc,%esp
80102492:	ff 75 f4             	pushl  -0xc(%ebp)
80102495:	e8 2e f6 ff ff       	call   80101ac8 <iunlock>
8010249a:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024a0:	e9 81 00 00 00       	jmp    80102526 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a5:	83 ec 04             	sub    $0x4,%esp
801024a8:	6a 00                	push   $0x0
801024aa:	ff 75 10             	pushl  0x10(%ebp)
801024ad:	ff 75 f4             	pushl  -0xc(%ebp)
801024b0:	e8 1d fd ff ff       	call   801021d2 <dirlookup>
801024b5:	83 c4 10             	add    $0x10,%esp
801024b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bf:	75 15                	jne    801024d6 <namex+0xce>
      iunlockput(ip);
801024c1:	83 ec 0c             	sub    $0xc,%esp
801024c4:	ff 75 f4             	pushl  -0xc(%ebp)
801024c7:	e8 5e f7 ff ff       	call   80101c2a <iunlockput>
801024cc:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cf:	b8 00 00 00 00       	mov    $0x0,%eax
801024d4:	eb 50                	jmp    80102526 <namex+0x11e>
    }
    iunlockput(ip);
801024d6:	83 ec 0c             	sub    $0xc,%esp
801024d9:	ff 75 f4             	pushl  -0xc(%ebp)
801024dc:	e8 49 f7 ff ff       	call   80101c2a <iunlockput>
801024e1:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024ea:	83 ec 08             	sub    $0x8,%esp
801024ed:	ff 75 10             	pushl  0x10(%ebp)
801024f0:	ff 75 08             	pushl  0x8(%ebp)
801024f3:	e8 6c fe ff ff       	call   80102364 <skipelem>
801024f8:	83 c4 10             	add    $0x10,%esp
801024fb:	89 45 08             	mov    %eax,0x8(%ebp)
801024fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102502:	0f 85 44 ff ff ff    	jne    8010244c <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102508:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010250c:	74 15                	je     80102523 <namex+0x11b>
    iput(ip);
8010250e:	83 ec 0c             	sub    $0xc,%esp
80102511:	ff 75 f4             	pushl  -0xc(%ebp)
80102514:	e8 21 f6 ff ff       	call   80101b3a <iput>
80102519:	83 c4 10             	add    $0x10,%esp
    return 0;
8010251c:	b8 00 00 00 00       	mov    $0x0,%eax
80102521:	eb 03                	jmp    80102526 <namex+0x11e>
  }
  return ip;
80102523:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102526:	c9                   	leave  
80102527:	c3                   	ret    

80102528 <namei>:

struct inode*
namei(char *path)
{
80102528:	55                   	push   %ebp
80102529:	89 e5                	mov    %esp,%ebp
8010252b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252e:	83 ec 04             	sub    $0x4,%esp
80102531:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102534:	50                   	push   %eax
80102535:	6a 00                	push   $0x0
80102537:	ff 75 08             	pushl  0x8(%ebp)
8010253a:	e8 c9 fe ff ff       	call   80102408 <namex>
8010253f:	83 c4 10             	add    $0x10,%esp
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010254a:	83 ec 04             	sub    $0x4,%esp
8010254d:	ff 75 0c             	pushl  0xc(%ebp)
80102550:	6a 01                	push   $0x1
80102552:	ff 75 08             	pushl  0x8(%ebp)
80102555:	e8 ae fe ff ff       	call   80102408 <namex>
8010255a:	83 c4 10             	add    $0x10,%esp
}
8010255d:	c9                   	leave  
8010255e:	c3                   	ret    

8010255f <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
8010255f:	55                   	push   %ebp
80102560:	89 e5                	mov    %esp,%ebp
80102562:	83 ec 14             	sub    $0x14,%esp
80102565:	8b 45 08             	mov    0x8(%ebp),%eax
80102568:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102570:	89 c2                	mov    %eax,%edx
80102572:	ec                   	in     (%dx),%al
80102573:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102576:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010257a:	c9                   	leave  
8010257b:	c3                   	ret    

8010257c <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010257c:	55                   	push   %ebp
8010257d:	89 e5                	mov    %esp,%ebp
8010257f:	57                   	push   %edi
80102580:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102581:	8b 55 08             	mov    0x8(%ebp),%edx
80102584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102587:	8b 45 10             	mov    0x10(%ebp),%eax
8010258a:	89 cb                	mov    %ecx,%ebx
8010258c:	89 df                	mov    %ebx,%edi
8010258e:	89 c1                	mov    %eax,%ecx
80102590:	fc                   	cld    
80102591:	f3 6d                	rep insl (%dx),%es:(%edi)
80102593:	89 c8                	mov    %ecx,%eax
80102595:	89 fb                	mov    %edi,%ebx
80102597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010259a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
8010259d:	90                   	nop
8010259e:	5b                   	pop    %ebx
8010259f:	5f                   	pop    %edi
801025a0:	5d                   	pop    %ebp
801025a1:	c3                   	ret    

801025a2 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025a2:	55                   	push   %ebp
801025a3:	89 e5                	mov    %esp,%ebp
801025a5:	83 ec 08             	sub    $0x8,%esp
801025a8:	8b 55 08             	mov    0x8(%ebp),%edx
801025ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801025ae:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025b2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025b5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025b9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025bd:	ee                   	out    %al,(%dx)
}
801025be:	90                   	nop
801025bf:	c9                   	leave  
801025c0:	c3                   	ret    

801025c1 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025c1:	55                   	push   %ebp
801025c2:	89 e5                	mov    %esp,%ebp
801025c4:	56                   	push   %esi
801025c5:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025c6:	8b 55 08             	mov    0x8(%ebp),%edx
801025c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025cc:	8b 45 10             	mov    0x10(%ebp),%eax
801025cf:	89 cb                	mov    %ecx,%ebx
801025d1:	89 de                	mov    %ebx,%esi
801025d3:	89 c1                	mov    %eax,%ecx
801025d5:	fc                   	cld    
801025d6:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025d8:	89 c8                	mov    %ecx,%eax
801025da:	89 f3                	mov    %esi,%ebx
801025dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025df:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025e2:	90                   	nop
801025e3:	5b                   	pop    %ebx
801025e4:	5e                   	pop    %esi
801025e5:	5d                   	pop    %ebp
801025e6:	c3                   	ret    

801025e7 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025e7:	55                   	push   %ebp
801025e8:	89 e5                	mov    %esp,%ebp
801025ea:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ed:	90                   	nop
801025ee:	68 f7 01 00 00       	push   $0x1f7
801025f3:	e8 67 ff ff ff       	call   8010255f <inb>
801025f8:	83 c4 04             	add    $0x4,%esp
801025fb:	0f b6 c0             	movzbl %al,%eax
801025fe:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102601:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102604:	25 c0 00 00 00       	and    $0xc0,%eax
80102609:	83 f8 40             	cmp    $0x40,%eax
8010260c:	75 e0                	jne    801025ee <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010260e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102612:	74 11                	je     80102625 <idewait+0x3e>
80102614:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102617:	83 e0 21             	and    $0x21,%eax
8010261a:	85 c0                	test   %eax,%eax
8010261c:	74 07                	je     80102625 <idewait+0x3e>
    return -1;
8010261e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102623:	eb 05                	jmp    8010262a <idewait+0x43>
  return 0;
80102625:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010262a:	c9                   	leave  
8010262b:	c3                   	ret    

8010262c <ideinit>:

void
ideinit(void)
{
8010262c:	55                   	push   %ebp
8010262d:	89 e5                	mov    %esp,%ebp
8010262f:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102632:	83 ec 08             	sub    $0x8,%esp
80102635:	68 ce 8b 10 80       	push   $0x80108bce
8010263a:	68 20 c6 10 80       	push   $0x8010c620
8010263f:	e8 38 2d 00 00       	call   8010537c <initlock>
80102644:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102647:	83 ec 0c             	sub    $0xc,%esp
8010264a:	6a 0e                	push   $0xe
8010264c:	e8 da 18 00 00       	call   80103f2b <picenable>
80102651:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102654:	a1 60 39 11 80       	mov    0x80113960,%eax
80102659:	83 e8 01             	sub    $0x1,%eax
8010265c:	83 ec 08             	sub    $0x8,%esp
8010265f:	50                   	push   %eax
80102660:	6a 0e                	push   $0xe
80102662:	e8 73 04 00 00       	call   80102ada <ioapicenable>
80102667:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010266a:	83 ec 0c             	sub    $0xc,%esp
8010266d:	6a 00                	push   $0x0
8010266f:	e8 73 ff ff ff       	call   801025e7 <idewait>
80102674:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102677:	83 ec 08             	sub    $0x8,%esp
8010267a:	68 f0 00 00 00       	push   $0xf0
8010267f:	68 f6 01 00 00       	push   $0x1f6
80102684:	e8 19 ff ff ff       	call   801025a2 <outb>
80102689:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010268c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102693:	eb 24                	jmp    801026b9 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102695:	83 ec 0c             	sub    $0xc,%esp
80102698:	68 f7 01 00 00       	push   $0x1f7
8010269d:	e8 bd fe ff ff       	call   8010255f <inb>
801026a2:	83 c4 10             	add    $0x10,%esp
801026a5:	84 c0                	test   %al,%al
801026a7:	74 0c                	je     801026b5 <ideinit+0x89>
      havedisk1 = 1;
801026a9:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
801026b0:	00 00 00 
      break;
801026b3:	eb 0d                	jmp    801026c2 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026b5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026b9:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026c0:	7e d3                	jle    80102695 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026c2:	83 ec 08             	sub    $0x8,%esp
801026c5:	68 e0 00 00 00       	push   $0xe0
801026ca:	68 f6 01 00 00       	push   $0x1f6
801026cf:	e8 ce fe ff ff       	call   801025a2 <outb>
801026d4:	83 c4 10             	add    $0x10,%esp
}
801026d7:	90                   	nop
801026d8:	c9                   	leave  
801026d9:	c3                   	ret    

801026da <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026da:	55                   	push   %ebp
801026db:	89 e5                	mov    %esp,%ebp
801026dd:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026e4:	75 0d                	jne    801026f3 <idestart+0x19>
    panic("idestart");
801026e6:	83 ec 0c             	sub    $0xc,%esp
801026e9:	68 d2 8b 10 80       	push   $0x80108bd2
801026ee:	e8 73 de ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801026f3:	8b 45 08             	mov    0x8(%ebp),%eax
801026f6:	8b 40 08             	mov    0x8(%eax),%eax
801026f9:	3d cf 07 00 00       	cmp    $0x7cf,%eax
801026fe:	76 0d                	jbe    8010270d <idestart+0x33>
    panic("incorrect blockno");
80102700:	83 ec 0c             	sub    $0xc,%esp
80102703:	68 db 8b 10 80       	push   $0x80108bdb
80102708:	e8 59 de ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010270d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	8b 50 08             	mov    0x8(%eax),%edx
8010271a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010271d:	0f af c2             	imul   %edx,%eax
80102720:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102723:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102727:	7e 0d                	jle    80102736 <idestart+0x5c>
80102729:	83 ec 0c             	sub    $0xc,%esp
8010272c:	68 d2 8b 10 80       	push   $0x80108bd2
80102731:	e8 30 de ff ff       	call   80100566 <panic>
  
  idewait(0);
80102736:	83 ec 0c             	sub    $0xc,%esp
80102739:	6a 00                	push   $0x0
8010273b:	e8 a7 fe ff ff       	call   801025e7 <idewait>
80102740:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102743:	83 ec 08             	sub    $0x8,%esp
80102746:	6a 00                	push   $0x0
80102748:	68 f6 03 00 00       	push   $0x3f6
8010274d:	e8 50 fe ff ff       	call   801025a2 <outb>
80102752:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	0f b6 c0             	movzbl %al,%eax
8010275b:	83 ec 08             	sub    $0x8,%esp
8010275e:	50                   	push   %eax
8010275f:	68 f2 01 00 00       	push   $0x1f2
80102764:	e8 39 fe ff ff       	call   801025a2 <outb>
80102769:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010276c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010276f:	0f b6 c0             	movzbl %al,%eax
80102772:	83 ec 08             	sub    $0x8,%esp
80102775:	50                   	push   %eax
80102776:	68 f3 01 00 00       	push   $0x1f3
8010277b:	e8 22 fe ff ff       	call   801025a2 <outb>
80102780:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102783:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102786:	c1 f8 08             	sar    $0x8,%eax
80102789:	0f b6 c0             	movzbl %al,%eax
8010278c:	83 ec 08             	sub    $0x8,%esp
8010278f:	50                   	push   %eax
80102790:	68 f4 01 00 00       	push   $0x1f4
80102795:	e8 08 fe ff ff       	call   801025a2 <outb>
8010279a:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
8010279d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a0:	c1 f8 10             	sar    $0x10,%eax
801027a3:	0f b6 c0             	movzbl %al,%eax
801027a6:	83 ec 08             	sub    $0x8,%esp
801027a9:	50                   	push   %eax
801027aa:	68 f5 01 00 00       	push   $0x1f5
801027af:	e8 ee fd ff ff       	call   801025a2 <outb>
801027b4:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027b7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ba:	8b 40 04             	mov    0x4(%eax),%eax
801027bd:	83 e0 01             	and    $0x1,%eax
801027c0:	c1 e0 04             	shl    $0x4,%eax
801027c3:	89 c2                	mov    %eax,%edx
801027c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027c8:	c1 f8 18             	sar    $0x18,%eax
801027cb:	83 e0 0f             	and    $0xf,%eax
801027ce:	09 d0                	or     %edx,%eax
801027d0:	83 c8 e0             	or     $0xffffffe0,%eax
801027d3:	0f b6 c0             	movzbl %al,%eax
801027d6:	83 ec 08             	sub    $0x8,%esp
801027d9:	50                   	push   %eax
801027da:	68 f6 01 00 00       	push   $0x1f6
801027df:	e8 be fd ff ff       	call   801025a2 <outb>
801027e4:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027e7:	8b 45 08             	mov    0x8(%ebp),%eax
801027ea:	8b 00                	mov    (%eax),%eax
801027ec:	83 e0 04             	and    $0x4,%eax
801027ef:	85 c0                	test   %eax,%eax
801027f1:	74 30                	je     80102823 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801027f3:	83 ec 08             	sub    $0x8,%esp
801027f6:	6a 30                	push   $0x30
801027f8:	68 f7 01 00 00       	push   $0x1f7
801027fd:	e8 a0 fd ff ff       	call   801025a2 <outb>
80102802:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102805:	8b 45 08             	mov    0x8(%ebp),%eax
80102808:	83 c0 18             	add    $0x18,%eax
8010280b:	83 ec 04             	sub    $0x4,%esp
8010280e:	68 80 00 00 00       	push   $0x80
80102813:	50                   	push   %eax
80102814:	68 f0 01 00 00       	push   $0x1f0
80102819:	e8 a3 fd ff ff       	call   801025c1 <outsl>
8010281e:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102821:	eb 12                	jmp    80102835 <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102823:	83 ec 08             	sub    $0x8,%esp
80102826:	6a 20                	push   $0x20
80102828:	68 f7 01 00 00       	push   $0x1f7
8010282d:	e8 70 fd ff ff       	call   801025a2 <outb>
80102832:	83 c4 10             	add    $0x10,%esp
  }
}
80102835:	90                   	nop
80102836:	c9                   	leave  
80102837:	c3                   	ret    

80102838 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102838:	55                   	push   %ebp
80102839:	89 e5                	mov    %esp,%ebp
8010283b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010283e:	83 ec 0c             	sub    $0xc,%esp
80102841:	68 20 c6 10 80       	push   $0x8010c620
80102846:	e8 53 2b 00 00       	call   8010539e <acquire>
8010284b:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
8010284e:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102853:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102856:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010285a:	75 15                	jne    80102871 <ideintr+0x39>
    release(&idelock);
8010285c:	83 ec 0c             	sub    $0xc,%esp
8010285f:	68 20 c6 10 80       	push   $0x8010c620
80102864:	e8 9c 2b 00 00       	call   80105405 <release>
80102869:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010286c:	e9 9a 00 00 00       	jmp    8010290b <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102871:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102874:	8b 40 14             	mov    0x14(%eax),%eax
80102877:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010287c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010287f:	8b 00                	mov    (%eax),%eax
80102881:	83 e0 04             	and    $0x4,%eax
80102884:	85 c0                	test   %eax,%eax
80102886:	75 2d                	jne    801028b5 <ideintr+0x7d>
80102888:	83 ec 0c             	sub    $0xc,%esp
8010288b:	6a 01                	push   $0x1
8010288d:	e8 55 fd ff ff       	call   801025e7 <idewait>
80102892:	83 c4 10             	add    $0x10,%esp
80102895:	85 c0                	test   %eax,%eax
80102897:	78 1c                	js     801028b5 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
80102899:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289c:	83 c0 18             	add    $0x18,%eax
8010289f:	83 ec 04             	sub    $0x4,%esp
801028a2:	68 80 00 00 00       	push   $0x80
801028a7:	50                   	push   %eax
801028a8:	68 f0 01 00 00       	push   $0x1f0
801028ad:	e8 ca fc ff ff       	call   8010257c <insl>
801028b2:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b8:	8b 00                	mov    (%eax),%eax
801028ba:	83 c8 02             	or     $0x2,%eax
801028bd:	89 c2                	mov    %eax,%edx
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c7:	8b 00                	mov    (%eax),%eax
801028c9:	83 e0 fb             	and    $0xfffffffb,%eax
801028cc:	89 c2                	mov    %eax,%edx
801028ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028d3:	83 ec 0c             	sub    $0xc,%esp
801028d6:	ff 75 f4             	pushl  -0xc(%ebp)
801028d9:	e8 06 26 00 00       	call   80104ee4 <wakeup>
801028de:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028e1:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028e6:	85 c0                	test   %eax,%eax
801028e8:	74 11                	je     801028fb <ideintr+0xc3>
    idestart(idequeue);
801028ea:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801028ef:	83 ec 0c             	sub    $0xc,%esp
801028f2:	50                   	push   %eax
801028f3:	e8 e2 fd ff ff       	call   801026da <idestart>
801028f8:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028fb:	83 ec 0c             	sub    $0xc,%esp
801028fe:	68 20 c6 10 80       	push   $0x8010c620
80102903:	e8 fd 2a 00 00       	call   80105405 <release>
80102908:	83 c4 10             	add    $0x10,%esp
}
8010290b:	c9                   	leave  
8010290c:	c3                   	ret    

8010290d <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010290d:	55                   	push   %ebp
8010290e:	89 e5                	mov    %esp,%ebp
80102910:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102913:	8b 45 08             	mov    0x8(%ebp),%eax
80102916:	8b 00                	mov    (%eax),%eax
80102918:	83 e0 01             	and    $0x1,%eax
8010291b:	85 c0                	test   %eax,%eax
8010291d:	75 0d                	jne    8010292c <iderw+0x1f>
    panic("iderw: buf not busy");
8010291f:	83 ec 0c             	sub    $0xc,%esp
80102922:	68 ed 8b 10 80       	push   $0x80108bed
80102927:	e8 3a dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010292c:	8b 45 08             	mov    0x8(%ebp),%eax
8010292f:	8b 00                	mov    (%eax),%eax
80102931:	83 e0 06             	and    $0x6,%eax
80102934:	83 f8 02             	cmp    $0x2,%eax
80102937:	75 0d                	jne    80102946 <iderw+0x39>
    panic("iderw: nothing to do");
80102939:	83 ec 0c             	sub    $0xc,%esp
8010293c:	68 01 8c 10 80       	push   $0x80108c01
80102941:	e8 20 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
80102946:	8b 45 08             	mov    0x8(%ebp),%eax
80102949:	8b 40 04             	mov    0x4(%eax),%eax
8010294c:	85 c0                	test   %eax,%eax
8010294e:	74 16                	je     80102966 <iderw+0x59>
80102950:	a1 58 c6 10 80       	mov    0x8010c658,%eax
80102955:	85 c0                	test   %eax,%eax
80102957:	75 0d                	jne    80102966 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
80102959:	83 ec 0c             	sub    $0xc,%esp
8010295c:	68 16 8c 10 80       	push   $0x80108c16
80102961:	e8 00 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102966:	83 ec 0c             	sub    $0xc,%esp
80102969:	68 20 c6 10 80       	push   $0x8010c620
8010296e:	e8 2b 2a 00 00       	call   8010539e <acquire>
80102973:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102976:	8b 45 08             	mov    0x8(%ebp),%eax
80102979:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102980:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
80102987:	eb 0b                	jmp    80102994 <iderw+0x87>
80102989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010298c:	8b 00                	mov    (%eax),%eax
8010298e:	83 c0 14             	add    $0x14,%eax
80102991:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102994:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102997:	8b 00                	mov    (%eax),%eax
80102999:	85 c0                	test   %eax,%eax
8010299b:	75 ec                	jne    80102989 <iderw+0x7c>
    ;
  *pp = b;
8010299d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a0:	8b 55 08             	mov    0x8(%ebp),%edx
801029a3:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029a5:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801029aa:	3b 45 08             	cmp    0x8(%ebp),%eax
801029ad:	75 23                	jne    801029d2 <iderw+0xc5>
    idestart(b);
801029af:	83 ec 0c             	sub    $0xc,%esp
801029b2:	ff 75 08             	pushl  0x8(%ebp)
801029b5:	e8 20 fd ff ff       	call   801026da <idestart>
801029ba:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029bd:	eb 13                	jmp    801029d2 <iderw+0xc5>
    sleep(b, &idelock);
801029bf:	83 ec 08             	sub    $0x8,%esp
801029c2:	68 20 c6 10 80       	push   $0x8010c620
801029c7:	ff 75 08             	pushl  0x8(%ebp)
801029ca:	e8 2e 24 00 00       	call   80104dfd <sleep>
801029cf:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029d2:	8b 45 08             	mov    0x8(%ebp),%eax
801029d5:	8b 00                	mov    (%eax),%eax
801029d7:	83 e0 06             	and    $0x6,%eax
801029da:	83 f8 02             	cmp    $0x2,%eax
801029dd:	75 e0                	jne    801029bf <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801029df:	83 ec 0c             	sub    $0xc,%esp
801029e2:	68 20 c6 10 80       	push   $0x8010c620
801029e7:	e8 19 2a 00 00       	call   80105405 <release>
801029ec:	83 c4 10             	add    $0x10,%esp
}
801029ef:	90                   	nop
801029f0:	c9                   	leave  
801029f1:	c3                   	ret    

801029f2 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029f2:	55                   	push   %ebp
801029f3:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f5:	a1 34 32 11 80       	mov    0x80113234,%eax
801029fa:	8b 55 08             	mov    0x8(%ebp),%edx
801029fd:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029ff:	a1 34 32 11 80       	mov    0x80113234,%eax
80102a04:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a07:	5d                   	pop    %ebp
80102a08:	c3                   	ret    

80102a09 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a09:	55                   	push   %ebp
80102a0a:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a0c:	a1 34 32 11 80       	mov    0x80113234,%eax
80102a11:	8b 55 08             	mov    0x8(%ebp),%edx
80102a14:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a16:	a1 34 32 11 80       	mov    0x80113234,%eax
80102a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a1e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a21:	90                   	nop
80102a22:	5d                   	pop    %ebp
80102a23:	c3                   	ret    

80102a24 <ioapicinit>:

void
ioapicinit(void)
{
80102a24:	55                   	push   %ebp
80102a25:	89 e5                	mov    %esp,%ebp
80102a27:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a2a:	a1 64 33 11 80       	mov    0x80113364,%eax
80102a2f:	85 c0                	test   %eax,%eax
80102a31:	0f 84 a0 00 00 00    	je     80102ad7 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a37:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
80102a3e:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a41:	6a 01                	push   $0x1
80102a43:	e8 aa ff ff ff       	call   801029f2 <ioapicread>
80102a48:	83 c4 04             	add    $0x4,%esp
80102a4b:	c1 e8 10             	shr    $0x10,%eax
80102a4e:	25 ff 00 00 00       	and    $0xff,%eax
80102a53:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a56:	6a 00                	push   $0x0
80102a58:	e8 95 ff ff ff       	call   801029f2 <ioapicread>
80102a5d:	83 c4 04             	add    $0x4,%esp
80102a60:	c1 e8 18             	shr    $0x18,%eax
80102a63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a66:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
80102a6d:	0f b6 c0             	movzbl %al,%eax
80102a70:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a73:	74 10                	je     80102a85 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a75:	83 ec 0c             	sub    $0xc,%esp
80102a78:	68 34 8c 10 80       	push   $0x80108c34
80102a7d:	e8 44 d9 ff ff       	call   801003c6 <cprintf>
80102a82:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a8c:	eb 3f                	jmp    80102acd <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a91:	83 c0 20             	add    $0x20,%eax
80102a94:	0d 00 00 01 00       	or     $0x10000,%eax
80102a99:	89 c2                	mov    %eax,%edx
80102a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a9e:	83 c0 08             	add    $0x8,%eax
80102aa1:	01 c0                	add    %eax,%eax
80102aa3:	83 ec 08             	sub    $0x8,%esp
80102aa6:	52                   	push   %edx
80102aa7:	50                   	push   %eax
80102aa8:	e8 5c ff ff ff       	call   80102a09 <ioapicwrite>
80102aad:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab3:	83 c0 08             	add    $0x8,%eax
80102ab6:	01 c0                	add    %eax,%eax
80102ab8:	83 c0 01             	add    $0x1,%eax
80102abb:	83 ec 08             	sub    $0x8,%esp
80102abe:	6a 00                	push   $0x0
80102ac0:	50                   	push   %eax
80102ac1:	e8 43 ff ff ff       	call   80102a09 <ioapicwrite>
80102ac6:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ac9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ad3:	7e b9                	jle    80102a8e <ioapicinit+0x6a>
80102ad5:	eb 01                	jmp    80102ad8 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102ad7:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ad8:	c9                   	leave  
80102ad9:	c3                   	ret    

80102ada <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ada:	55                   	push   %ebp
80102adb:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102add:	a1 64 33 11 80       	mov    0x80113364,%eax
80102ae2:	85 c0                	test   %eax,%eax
80102ae4:	74 39                	je     80102b1f <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ae9:	83 c0 20             	add    $0x20,%eax
80102aec:	89 c2                	mov    %eax,%edx
80102aee:	8b 45 08             	mov    0x8(%ebp),%eax
80102af1:	83 c0 08             	add    $0x8,%eax
80102af4:	01 c0                	add    %eax,%eax
80102af6:	52                   	push   %edx
80102af7:	50                   	push   %eax
80102af8:	e8 0c ff ff ff       	call   80102a09 <ioapicwrite>
80102afd:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b00:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b03:	c1 e0 18             	shl    $0x18,%eax
80102b06:	89 c2                	mov    %eax,%edx
80102b08:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0b:	83 c0 08             	add    $0x8,%eax
80102b0e:	01 c0                	add    %eax,%eax
80102b10:	83 c0 01             	add    $0x1,%eax
80102b13:	52                   	push   %edx
80102b14:	50                   	push   %eax
80102b15:	e8 ef fe ff ff       	call   80102a09 <ioapicwrite>
80102b1a:	83 c4 08             	add    $0x8,%esp
80102b1d:	eb 01                	jmp    80102b20 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102b1f:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102b20:	c9                   	leave  
80102b21:	c3                   	ret    

80102b22 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b22:	55                   	push   %ebp
80102b23:	89 e5                	mov    %esp,%ebp
80102b25:	8b 45 08             	mov    0x8(%ebp),%eax
80102b28:	05 00 00 00 80       	add    $0x80000000,%eax
80102b2d:	5d                   	pop    %ebp
80102b2e:	c3                   	ret    

80102b2f <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b35:	83 ec 08             	sub    $0x8,%esp
80102b38:	68 66 8c 10 80       	push   $0x80108c66
80102b3d:	68 40 32 11 80       	push   $0x80113240
80102b42:	e8 35 28 00 00       	call   8010537c <initlock>
80102b47:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b4a:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102b51:	00 00 00 
  freerange(vstart, vend);
80102b54:	83 ec 08             	sub    $0x8,%esp
80102b57:	ff 75 0c             	pushl  0xc(%ebp)
80102b5a:	ff 75 08             	pushl  0x8(%ebp)
80102b5d:	e8 2a 00 00 00       	call   80102b8c <freerange>
80102b62:	83 c4 10             	add    $0x10,%esp
}
80102b65:	90                   	nop
80102b66:	c9                   	leave  
80102b67:	c3                   	ret    

80102b68 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b68:	55                   	push   %ebp
80102b69:	89 e5                	mov    %esp,%ebp
80102b6b:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b6e:	83 ec 08             	sub    $0x8,%esp
80102b71:	ff 75 0c             	pushl  0xc(%ebp)
80102b74:	ff 75 08             	pushl  0x8(%ebp)
80102b77:	e8 10 00 00 00       	call   80102b8c <freerange>
80102b7c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b7f:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102b86:	00 00 00 
}
80102b89:	90                   	nop
80102b8a:	c9                   	leave  
80102b8b:	c3                   	ret    

80102b8c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b8c:	55                   	push   %ebp
80102b8d:	89 e5                	mov    %esp,%ebp
80102b8f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b92:	8b 45 08             	mov    0x8(%ebp),%eax
80102b95:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102ba2:	eb 15                	jmp    80102bb9 <freerange+0x2d>
    kfree(p);
80102ba4:	83 ec 0c             	sub    $0xc,%esp
80102ba7:	ff 75 f4             	pushl  -0xc(%ebp)
80102baa:	e8 1a 00 00 00       	call   80102bc9 <kfree>
80102baf:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bbc:	05 00 10 00 00       	add    $0x1000,%eax
80102bc1:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bc4:	76 de                	jbe    80102ba4 <freerange+0x18>
    kfree(p);
}
80102bc6:	90                   	nop
80102bc7:	c9                   	leave  
80102bc8:	c3                   	ret    

80102bc9 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bc9:	55                   	push   %ebp
80102bca:	89 e5                	mov    %esp,%ebp
80102bcc:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd2:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bd7:	85 c0                	test   %eax,%eax
80102bd9:	75 1b                	jne    80102bf6 <kfree+0x2d>
80102bdb:	81 7d 08 1c 66 11 80 	cmpl   $0x8011661c,0x8(%ebp)
80102be2:	72 12                	jb     80102bf6 <kfree+0x2d>
80102be4:	ff 75 08             	pushl  0x8(%ebp)
80102be7:	e8 36 ff ff ff       	call   80102b22 <v2p>
80102bec:	83 c4 04             	add    $0x4,%esp
80102bef:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bf4:	76 0d                	jbe    80102c03 <kfree+0x3a>
    panic("kfree");
80102bf6:	83 ec 0c             	sub    $0xc,%esp
80102bf9:	68 6b 8c 10 80       	push   $0x80108c6b
80102bfe:	e8 63 d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c03:	83 ec 04             	sub    $0x4,%esp
80102c06:	68 00 10 00 00       	push   $0x1000
80102c0b:	6a 01                	push   $0x1
80102c0d:	ff 75 08             	pushl  0x8(%ebp)
80102c10:	e8 ec 29 00 00       	call   80105601 <memset>
80102c15:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c18:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c1d:	85 c0                	test   %eax,%eax
80102c1f:	74 10                	je     80102c31 <kfree+0x68>
    acquire(&kmem.lock);
80102c21:	83 ec 0c             	sub    $0xc,%esp
80102c24:	68 40 32 11 80       	push   $0x80113240
80102c29:	e8 70 27 00 00       	call   8010539e <acquire>
80102c2e:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c31:	8b 45 08             	mov    0x8(%ebp),%eax
80102c34:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c37:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c40:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c45:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102c4a:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c4f:	85 c0                	test   %eax,%eax
80102c51:	74 10                	je     80102c63 <kfree+0x9a>
    release(&kmem.lock);
80102c53:	83 ec 0c             	sub    $0xc,%esp
80102c56:	68 40 32 11 80       	push   $0x80113240
80102c5b:	e8 a5 27 00 00       	call   80105405 <release>
80102c60:	83 c4 10             	add    $0x10,%esp
}
80102c63:	90                   	nop
80102c64:	c9                   	leave  
80102c65:	c3                   	ret    

80102c66 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c66:	55                   	push   %ebp
80102c67:	89 e5                	mov    %esp,%ebp
80102c69:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c6c:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c71:	85 c0                	test   %eax,%eax
80102c73:	74 10                	je     80102c85 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c75:	83 ec 0c             	sub    $0xc,%esp
80102c78:	68 40 32 11 80       	push   $0x80113240
80102c7d:	e8 1c 27 00 00       	call   8010539e <acquire>
80102c82:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c85:	a1 78 32 11 80       	mov    0x80113278,%eax
80102c8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c8d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c91:	74 0a                	je     80102c9d <kalloc+0x37>
    kmem.freelist = r->next;
80102c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c96:	8b 00                	mov    (%eax),%eax
80102c98:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102c9d:	a1 74 32 11 80       	mov    0x80113274,%eax
80102ca2:	85 c0                	test   %eax,%eax
80102ca4:	74 10                	je     80102cb6 <kalloc+0x50>
    release(&kmem.lock);
80102ca6:	83 ec 0c             	sub    $0xc,%esp
80102ca9:	68 40 32 11 80       	push   $0x80113240
80102cae:	e8 52 27 00 00       	call   80105405 <release>
80102cb3:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102cb9:	c9                   	leave  
80102cba:	c3                   	ret    

80102cbb <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102cbb:	55                   	push   %ebp
80102cbc:	89 e5                	mov    %esp,%ebp
80102cbe:	83 ec 14             	sub    $0x14,%esp
80102cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cc8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102ccc:	89 c2                	mov    %eax,%edx
80102cce:	ec                   	in     (%dx),%al
80102ccf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cd2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cd6:	c9                   	leave  
80102cd7:	c3                   	ret    

80102cd8 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cd8:	55                   	push   %ebp
80102cd9:	89 e5                	mov    %esp,%ebp
80102cdb:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cde:	6a 64                	push   $0x64
80102ce0:	e8 d6 ff ff ff       	call   80102cbb <inb>
80102ce5:	83 c4 04             	add    $0x4,%esp
80102ce8:	0f b6 c0             	movzbl %al,%eax
80102ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cf1:	83 e0 01             	and    $0x1,%eax
80102cf4:	85 c0                	test   %eax,%eax
80102cf6:	75 0a                	jne    80102d02 <kbdgetc+0x2a>
    return -1;
80102cf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102cfd:	e9 23 01 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d02:	6a 60                	push   $0x60
80102d04:	e8 b2 ff ff ff       	call   80102cbb <inb>
80102d09:	83 c4 04             	add    $0x4,%esp
80102d0c:	0f b6 c0             	movzbl %al,%eax
80102d0f:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d12:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d19:	75 17                	jne    80102d32 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d1b:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d20:	83 c8 40             	or     $0x40,%eax
80102d23:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102d28:	b8 00 00 00 00       	mov    $0x0,%eax
80102d2d:	e9 f3 00 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d35:	25 80 00 00 00       	and    $0x80,%eax
80102d3a:	85 c0                	test   %eax,%eax
80102d3c:	74 45                	je     80102d83 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d3e:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d43:	83 e0 40             	and    $0x40,%eax
80102d46:	85 c0                	test   %eax,%eax
80102d48:	75 08                	jne    80102d52 <kbdgetc+0x7a>
80102d4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d4d:	83 e0 7f             	and    $0x7f,%eax
80102d50:	eb 03                	jmp    80102d55 <kbdgetc+0x7d>
80102d52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d55:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d5b:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d60:	0f b6 00             	movzbl (%eax),%eax
80102d63:	83 c8 40             	or     $0x40,%eax
80102d66:	0f b6 c0             	movzbl %al,%eax
80102d69:	f7 d0                	not    %eax
80102d6b:	89 c2                	mov    %eax,%edx
80102d6d:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d72:	21 d0                	and    %edx,%eax
80102d74:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102d79:	b8 00 00 00 00       	mov    $0x0,%eax
80102d7e:	e9 a2 00 00 00       	jmp    80102e25 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d83:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d88:	83 e0 40             	and    $0x40,%eax
80102d8b:	85 c0                	test   %eax,%eax
80102d8d:	74 14                	je     80102da3 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d8f:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d96:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d9b:	83 e0 bf             	and    $0xffffffbf,%eax
80102d9e:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102da3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da6:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102dab:	0f b6 00             	movzbl (%eax),%eax
80102dae:	0f b6 d0             	movzbl %al,%edx
80102db1:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102db6:	09 d0                	or     %edx,%eax
80102db8:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102dbd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dc0:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102dc5:	0f b6 00             	movzbl (%eax),%eax
80102dc8:	0f b6 d0             	movzbl %al,%edx
80102dcb:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102dd0:	31 d0                	xor    %edx,%eax
80102dd2:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dd7:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ddc:	83 e0 03             	and    $0x3,%eax
80102ddf:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102de6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102de9:	01 d0                	add    %edx,%eax
80102deb:	0f b6 00             	movzbl (%eax),%eax
80102dee:	0f b6 c0             	movzbl %al,%eax
80102df1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102df4:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102df9:	83 e0 08             	and    $0x8,%eax
80102dfc:	85 c0                	test   %eax,%eax
80102dfe:	74 22                	je     80102e22 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e00:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e04:	76 0c                	jbe    80102e12 <kbdgetc+0x13a>
80102e06:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e0a:	77 06                	ja     80102e12 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e0c:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e10:	eb 10                	jmp    80102e22 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e12:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e16:	76 0a                	jbe    80102e22 <kbdgetc+0x14a>
80102e18:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e1c:	77 04                	ja     80102e22 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e1e:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e22:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e25:	c9                   	leave  
80102e26:	c3                   	ret    

80102e27 <kbdintr>:

void
kbdintr(void)
{
80102e27:	55                   	push   %ebp
80102e28:	89 e5                	mov    %esp,%ebp
80102e2a:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e2d:	83 ec 0c             	sub    $0xc,%esp
80102e30:	68 d8 2c 10 80       	push   $0x80102cd8
80102e35:	e8 bf d9 ff ff       	call   801007f9 <consoleintr>
80102e3a:	83 c4 10             	add    $0x10,%esp
}
80102e3d:	90                   	nop
80102e3e:	c9                   	leave  
80102e3f:	c3                   	ret    

80102e40 <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80102e40:	55                   	push   %ebp
80102e41:	89 e5                	mov    %esp,%ebp
80102e43:	83 ec 14             	sub    $0x14,%esp
80102e46:	8b 45 08             	mov    0x8(%ebp),%eax
80102e49:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e4d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e51:	89 c2                	mov    %eax,%edx
80102e53:	ec                   	in     (%dx),%al
80102e54:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e57:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e5b:	c9                   	leave  
80102e5c:	c3                   	ret    

80102e5d <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e5d:	55                   	push   %ebp
80102e5e:	89 e5                	mov    %esp,%ebp
80102e60:	83 ec 08             	sub    $0x8,%esp
80102e63:	8b 55 08             	mov    0x8(%ebp),%edx
80102e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e69:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e6d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e70:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e74:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e78:	ee                   	out    %al,(%dx)
}
80102e79:	90                   	nop
80102e7a:	c9                   	leave  
80102e7b:	c3                   	ret    

80102e7c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e82:	9c                   	pushf  
80102e83:	58                   	pop    %eax
80102e84:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e87:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e8a:	c9                   	leave  
80102e8b:	c3                   	ret    

80102e8c <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e8c:	55                   	push   %ebp
80102e8d:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e8f:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e94:	8b 55 08             	mov    0x8(%ebp),%edx
80102e97:	c1 e2 02             	shl    $0x2,%edx
80102e9a:	01 c2                	add    %eax,%edx
80102e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e9f:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ea1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102ea6:	83 c0 20             	add    $0x20,%eax
80102ea9:	8b 00                	mov    (%eax),%eax
}
80102eab:	90                   	nop
80102eac:	5d                   	pop    %ebp
80102ead:	c3                   	ret    

80102eae <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102eb1:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102eb6:	85 c0                	test   %eax,%eax
80102eb8:	0f 84 0b 01 00 00    	je     80102fc9 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ebe:	68 3f 01 00 00       	push   $0x13f
80102ec3:	6a 3c                	push   $0x3c
80102ec5:	e8 c2 ff ff ff       	call   80102e8c <lapicw>
80102eca:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ecd:	6a 0b                	push   $0xb
80102ecf:	68 f8 00 00 00       	push   $0xf8
80102ed4:	e8 b3 ff ff ff       	call   80102e8c <lapicw>
80102ed9:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102edc:	68 20 00 02 00       	push   $0x20020
80102ee1:	68 c8 00 00 00       	push   $0xc8
80102ee6:	e8 a1 ff ff ff       	call   80102e8c <lapicw>
80102eeb:	83 c4 08             	add    $0x8,%esp
  // lapicw(TICR, 10000000); 
  lapicw(TICR, 1000000000/TPS); // PSU CS333. Makes ticks per second programmable
80102eee:	68 40 42 0f 00       	push   $0xf4240
80102ef3:	68 e0 00 00 00       	push   $0xe0
80102ef8:	e8 8f ff ff ff       	call   80102e8c <lapicw>
80102efd:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f00:	68 00 00 01 00       	push   $0x10000
80102f05:	68 d4 00 00 00       	push   $0xd4
80102f0a:	e8 7d ff ff ff       	call   80102e8c <lapicw>
80102f0f:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f12:	68 00 00 01 00       	push   $0x10000
80102f17:	68 d8 00 00 00       	push   $0xd8
80102f1c:	e8 6b ff ff ff       	call   80102e8c <lapicw>
80102f21:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f24:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f29:	83 c0 30             	add    $0x30,%eax
80102f2c:	8b 00                	mov    (%eax),%eax
80102f2e:	c1 e8 10             	shr    $0x10,%eax
80102f31:	0f b6 c0             	movzbl %al,%eax
80102f34:	83 f8 03             	cmp    $0x3,%eax
80102f37:	76 12                	jbe    80102f4b <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f39:	68 00 00 01 00       	push   $0x10000
80102f3e:	68 d0 00 00 00       	push   $0xd0
80102f43:	e8 44 ff ff ff       	call   80102e8c <lapicw>
80102f48:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f4b:	6a 33                	push   $0x33
80102f4d:	68 dc 00 00 00       	push   $0xdc
80102f52:	e8 35 ff ff ff       	call   80102e8c <lapicw>
80102f57:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f5a:	6a 00                	push   $0x0
80102f5c:	68 a0 00 00 00       	push   $0xa0
80102f61:	e8 26 ff ff ff       	call   80102e8c <lapicw>
80102f66:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f69:	6a 00                	push   $0x0
80102f6b:	68 a0 00 00 00       	push   $0xa0
80102f70:	e8 17 ff ff ff       	call   80102e8c <lapicw>
80102f75:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f78:	6a 00                	push   $0x0
80102f7a:	6a 2c                	push   $0x2c
80102f7c:	e8 0b ff ff ff       	call   80102e8c <lapicw>
80102f81:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f84:	6a 00                	push   $0x0
80102f86:	68 c4 00 00 00       	push   $0xc4
80102f8b:	e8 fc fe ff ff       	call   80102e8c <lapicw>
80102f90:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f93:	68 00 85 08 00       	push   $0x88500
80102f98:	68 c0 00 00 00       	push   $0xc0
80102f9d:	e8 ea fe ff ff       	call   80102e8c <lapicw>
80102fa2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fa5:	90                   	nop
80102fa6:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102fab:	05 00 03 00 00       	add    $0x300,%eax
80102fb0:	8b 00                	mov    (%eax),%eax
80102fb2:	25 00 10 00 00       	and    $0x1000,%eax
80102fb7:	85 c0                	test   %eax,%eax
80102fb9:	75 eb                	jne    80102fa6 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fbb:	6a 00                	push   $0x0
80102fbd:	6a 20                	push   $0x20
80102fbf:	e8 c8 fe ff ff       	call   80102e8c <lapicw>
80102fc4:	83 c4 08             	add    $0x8,%esp
80102fc7:	eb 01                	jmp    80102fca <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102fc9:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102fca:	c9                   	leave  
80102fcb:	c3                   	ret    

80102fcc <cpunum>:

int
cpunum(void)
{
80102fcc:	55                   	push   %ebp
80102fcd:	89 e5                	mov    %esp,%ebp
80102fcf:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fd2:	e8 a5 fe ff ff       	call   80102e7c <readeflags>
80102fd7:	25 00 02 00 00       	and    $0x200,%eax
80102fdc:	85 c0                	test   %eax,%eax
80102fde:	74 26                	je     80103006 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fe0:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102fe5:	8d 50 01             	lea    0x1(%eax),%edx
80102fe8:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102fee:	85 c0                	test   %eax,%eax
80102ff0:	75 14                	jne    80103006 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102ff2:	8b 45 04             	mov    0x4(%ebp),%eax
80102ff5:	83 ec 08             	sub    $0x8,%esp
80102ff8:	50                   	push   %eax
80102ff9:	68 74 8c 10 80       	push   $0x80108c74
80102ffe:	e8 c3 d3 ff ff       	call   801003c6 <cprintf>
80103003:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103006:	a1 7c 32 11 80       	mov    0x8011327c,%eax
8010300b:	85 c0                	test   %eax,%eax
8010300d:	74 0f                	je     8010301e <cpunum+0x52>
    return lapic[ID]>>24;
8010300f:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80103014:	83 c0 20             	add    $0x20,%eax
80103017:	8b 00                	mov    (%eax),%eax
80103019:	c1 e8 18             	shr    $0x18,%eax
8010301c:	eb 05                	jmp    80103023 <cpunum+0x57>
  return 0;
8010301e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103023:	c9                   	leave  
80103024:	c3                   	ret    

80103025 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103025:	55                   	push   %ebp
80103026:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103028:	a1 7c 32 11 80       	mov    0x8011327c,%eax
8010302d:	85 c0                	test   %eax,%eax
8010302f:	74 0c                	je     8010303d <lapiceoi+0x18>
    lapicw(EOI, 0);
80103031:	6a 00                	push   $0x0
80103033:	6a 2c                	push   $0x2c
80103035:	e8 52 fe ff ff       	call   80102e8c <lapicw>
8010303a:	83 c4 08             	add    $0x8,%esp
}
8010303d:	90                   	nop
8010303e:	c9                   	leave  
8010303f:	c3                   	ret    

80103040 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103040:	55                   	push   %ebp
80103041:	89 e5                	mov    %esp,%ebp
}
80103043:	90                   	nop
80103044:	5d                   	pop    %ebp
80103045:	c3                   	ret    

80103046 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103046:	55                   	push   %ebp
80103047:	89 e5                	mov    %esp,%ebp
80103049:	83 ec 14             	sub    $0x14,%esp
8010304c:	8b 45 08             	mov    0x8(%ebp),%eax
8010304f:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103052:	6a 0f                	push   $0xf
80103054:	6a 70                	push   $0x70
80103056:	e8 02 fe ff ff       	call   80102e5d <outb>
8010305b:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010305e:	6a 0a                	push   $0xa
80103060:	6a 71                	push   $0x71
80103062:	e8 f6 fd ff ff       	call   80102e5d <outb>
80103067:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010306a:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103071:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103074:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103079:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010307c:	83 c0 02             	add    $0x2,%eax
8010307f:	8b 55 0c             	mov    0xc(%ebp),%edx
80103082:	c1 ea 04             	shr    $0x4,%edx
80103085:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103088:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010308c:	c1 e0 18             	shl    $0x18,%eax
8010308f:	50                   	push   %eax
80103090:	68 c4 00 00 00       	push   $0xc4
80103095:	e8 f2 fd ff ff       	call   80102e8c <lapicw>
8010309a:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010309d:	68 00 c5 00 00       	push   $0xc500
801030a2:	68 c0 00 00 00       	push   $0xc0
801030a7:	e8 e0 fd ff ff       	call   80102e8c <lapicw>
801030ac:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030af:	68 c8 00 00 00       	push   $0xc8
801030b4:	e8 87 ff ff ff       	call   80103040 <microdelay>
801030b9:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030bc:	68 00 85 00 00       	push   $0x8500
801030c1:	68 c0 00 00 00       	push   $0xc0
801030c6:	e8 c1 fd ff ff       	call   80102e8c <lapicw>
801030cb:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030ce:	6a 64                	push   $0x64
801030d0:	e8 6b ff ff ff       	call   80103040 <microdelay>
801030d5:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030d8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030df:	eb 3d                	jmp    8010311e <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030e1:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030e5:	c1 e0 18             	shl    $0x18,%eax
801030e8:	50                   	push   %eax
801030e9:	68 c4 00 00 00       	push   $0xc4
801030ee:	e8 99 fd ff ff       	call   80102e8c <lapicw>
801030f3:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030f6:	8b 45 0c             	mov    0xc(%ebp),%eax
801030f9:	c1 e8 0c             	shr    $0xc,%eax
801030fc:	80 cc 06             	or     $0x6,%ah
801030ff:	50                   	push   %eax
80103100:	68 c0 00 00 00       	push   $0xc0
80103105:	e8 82 fd ff ff       	call   80102e8c <lapicw>
8010310a:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010310d:	68 c8 00 00 00       	push   $0xc8
80103112:	e8 29 ff ff ff       	call   80103040 <microdelay>
80103117:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010311a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010311e:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103122:	7e bd                	jle    801030e1 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103124:	90                   	nop
80103125:	c9                   	leave  
80103126:	c3                   	ret    

80103127 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103127:	55                   	push   %ebp
80103128:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010312a:	8b 45 08             	mov    0x8(%ebp),%eax
8010312d:	0f b6 c0             	movzbl %al,%eax
80103130:	50                   	push   %eax
80103131:	6a 70                	push   $0x70
80103133:	e8 25 fd ff ff       	call   80102e5d <outb>
80103138:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010313b:	68 c8 00 00 00       	push   $0xc8
80103140:	e8 fb fe ff ff       	call   80103040 <microdelay>
80103145:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103148:	6a 71                	push   $0x71
8010314a:	e8 f1 fc ff ff       	call   80102e40 <inb>
8010314f:	83 c4 04             	add    $0x4,%esp
80103152:	0f b6 c0             	movzbl %al,%eax
}
80103155:	c9                   	leave  
80103156:	c3                   	ret    

80103157 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103157:	55                   	push   %ebp
80103158:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010315a:	6a 00                	push   $0x0
8010315c:	e8 c6 ff ff ff       	call   80103127 <cmos_read>
80103161:	83 c4 04             	add    $0x4,%esp
80103164:	89 c2                	mov    %eax,%edx
80103166:	8b 45 08             	mov    0x8(%ebp),%eax
80103169:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
8010316b:	6a 02                	push   $0x2
8010316d:	e8 b5 ff ff ff       	call   80103127 <cmos_read>
80103172:	83 c4 04             	add    $0x4,%esp
80103175:	89 c2                	mov    %eax,%edx
80103177:	8b 45 08             	mov    0x8(%ebp),%eax
8010317a:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
8010317d:	6a 04                	push   $0x4
8010317f:	e8 a3 ff ff ff       	call   80103127 <cmos_read>
80103184:	83 c4 04             	add    $0x4,%esp
80103187:	89 c2                	mov    %eax,%edx
80103189:	8b 45 08             	mov    0x8(%ebp),%eax
8010318c:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
8010318f:	6a 07                	push   $0x7
80103191:	e8 91 ff ff ff       	call   80103127 <cmos_read>
80103196:	83 c4 04             	add    $0x4,%esp
80103199:	89 c2                	mov    %eax,%edx
8010319b:	8b 45 08             	mov    0x8(%ebp),%eax
8010319e:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
801031a1:	6a 08                	push   $0x8
801031a3:	e8 7f ff ff ff       	call   80103127 <cmos_read>
801031a8:	83 c4 04             	add    $0x4,%esp
801031ab:	89 c2                	mov    %eax,%edx
801031ad:	8b 45 08             	mov    0x8(%ebp),%eax
801031b0:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
801031b3:	6a 09                	push   $0x9
801031b5:	e8 6d ff ff ff       	call   80103127 <cmos_read>
801031ba:	83 c4 04             	add    $0x4,%esp
801031bd:	89 c2                	mov    %eax,%edx
801031bf:	8b 45 08             	mov    0x8(%ebp),%eax
801031c2:	89 50 14             	mov    %edx,0x14(%eax)
}
801031c5:	90                   	nop
801031c6:	c9                   	leave  
801031c7:	c3                   	ret    

801031c8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031c8:	55                   	push   %ebp
801031c9:	89 e5                	mov    %esp,%ebp
801031cb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031ce:	6a 0b                	push   $0xb
801031d0:	e8 52 ff ff ff       	call   80103127 <cmos_read>
801031d5:	83 c4 04             	add    $0x4,%esp
801031d8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031de:	83 e0 04             	and    $0x4,%eax
801031e1:	85 c0                	test   %eax,%eax
801031e3:	0f 94 c0             	sete   %al
801031e6:	0f b6 c0             	movzbl %al,%eax
801031e9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031ec:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031ef:	50                   	push   %eax
801031f0:	e8 62 ff ff ff       	call   80103157 <fill_rtcdate>
801031f5:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031f8:	6a 0a                	push   $0xa
801031fa:	e8 28 ff ff ff       	call   80103127 <cmos_read>
801031ff:	83 c4 04             	add    $0x4,%esp
80103202:	25 80 00 00 00       	and    $0x80,%eax
80103207:	85 c0                	test   %eax,%eax
80103209:	75 27                	jne    80103232 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010320b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010320e:	50                   	push   %eax
8010320f:	e8 43 ff ff ff       	call   80103157 <fill_rtcdate>
80103214:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103217:	83 ec 04             	sub    $0x4,%esp
8010321a:	6a 18                	push   $0x18
8010321c:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010321f:	50                   	push   %eax
80103220:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103223:	50                   	push   %eax
80103224:	e8 3f 24 00 00       	call   80105668 <memcmp>
80103229:	83 c4 10             	add    $0x10,%esp
8010322c:	85 c0                	test   %eax,%eax
8010322e:	74 05                	je     80103235 <cmostime+0x6d>
80103230:	eb ba                	jmp    801031ec <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103232:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103233:	eb b7                	jmp    801031ec <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103235:	90                   	nop
  }

  // convert
  if (bcd) {
80103236:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010323a:	0f 84 b4 00 00 00    	je     801032f4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103240:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103243:	c1 e8 04             	shr    $0x4,%eax
80103246:	89 c2                	mov    %eax,%edx
80103248:	89 d0                	mov    %edx,%eax
8010324a:	c1 e0 02             	shl    $0x2,%eax
8010324d:	01 d0                	add    %edx,%eax
8010324f:	01 c0                	add    %eax,%eax
80103251:	89 c2                	mov    %eax,%edx
80103253:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103256:	83 e0 0f             	and    $0xf,%eax
80103259:	01 d0                	add    %edx,%eax
8010325b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
8010325e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103261:	c1 e8 04             	shr    $0x4,%eax
80103264:	89 c2                	mov    %eax,%edx
80103266:	89 d0                	mov    %edx,%eax
80103268:	c1 e0 02             	shl    $0x2,%eax
8010326b:	01 d0                	add    %edx,%eax
8010326d:	01 c0                	add    %eax,%eax
8010326f:	89 c2                	mov    %eax,%edx
80103271:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103274:	83 e0 0f             	and    $0xf,%eax
80103277:	01 d0                	add    %edx,%eax
80103279:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
8010327c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010327f:	c1 e8 04             	shr    $0x4,%eax
80103282:	89 c2                	mov    %eax,%edx
80103284:	89 d0                	mov    %edx,%eax
80103286:	c1 e0 02             	shl    $0x2,%eax
80103289:	01 d0                	add    %edx,%eax
8010328b:	01 c0                	add    %eax,%eax
8010328d:	89 c2                	mov    %eax,%edx
8010328f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103292:	83 e0 0f             	and    $0xf,%eax
80103295:	01 d0                	add    %edx,%eax
80103297:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010329a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010329d:	c1 e8 04             	shr    $0x4,%eax
801032a0:	89 c2                	mov    %eax,%edx
801032a2:	89 d0                	mov    %edx,%eax
801032a4:	c1 e0 02             	shl    $0x2,%eax
801032a7:	01 d0                	add    %edx,%eax
801032a9:	01 c0                	add    %eax,%eax
801032ab:	89 c2                	mov    %eax,%edx
801032ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b0:	83 e0 0f             	and    $0xf,%eax
801032b3:	01 d0                	add    %edx,%eax
801032b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032bb:	c1 e8 04             	shr    $0x4,%eax
801032be:	89 c2                	mov    %eax,%edx
801032c0:	89 d0                	mov    %edx,%eax
801032c2:	c1 e0 02             	shl    $0x2,%eax
801032c5:	01 d0                	add    %edx,%eax
801032c7:	01 c0                	add    %eax,%eax
801032c9:	89 c2                	mov    %eax,%edx
801032cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032ce:	83 e0 0f             	and    $0xf,%eax
801032d1:	01 d0                	add    %edx,%eax
801032d3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d9:	c1 e8 04             	shr    $0x4,%eax
801032dc:	89 c2                	mov    %eax,%edx
801032de:	89 d0                	mov    %edx,%eax
801032e0:	c1 e0 02             	shl    $0x2,%eax
801032e3:	01 d0                	add    %edx,%eax
801032e5:	01 c0                	add    %eax,%eax
801032e7:	89 c2                	mov    %eax,%edx
801032e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032ec:	83 e0 0f             	and    $0xf,%eax
801032ef:	01 d0                	add    %edx,%eax
801032f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032f4:	8b 45 08             	mov    0x8(%ebp),%eax
801032f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032fa:	89 10                	mov    %edx,(%eax)
801032fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032ff:	89 50 04             	mov    %edx,0x4(%eax)
80103302:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103305:	89 50 08             	mov    %edx,0x8(%eax)
80103308:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010330b:	89 50 0c             	mov    %edx,0xc(%eax)
8010330e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103311:	89 50 10             	mov    %edx,0x10(%eax)
80103314:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103317:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
8010331a:	8b 45 08             	mov    0x8(%ebp),%eax
8010331d:	8b 40 14             	mov    0x14(%eax),%eax
80103320:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103326:	8b 45 08             	mov    0x8(%ebp),%eax
80103329:	89 50 14             	mov    %edx,0x14(%eax)
}
8010332c:	90                   	nop
8010332d:	c9                   	leave  
8010332e:	c3                   	ret    

8010332f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010332f:	55                   	push   %ebp
80103330:	89 e5                	mov    %esp,%ebp
80103332:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103335:	83 ec 08             	sub    $0x8,%esp
80103338:	68 a0 8c 10 80       	push   $0x80108ca0
8010333d:	68 80 32 11 80       	push   $0x80113280
80103342:	e8 35 20 00 00       	call   8010537c <initlock>
80103347:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010334a:	83 ec 08             	sub    $0x8,%esp
8010334d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103350:	50                   	push   %eax
80103351:	ff 75 08             	pushl  0x8(%ebp)
80103354:	e8 2b e0 ff ff       	call   80101384 <readsb>
80103359:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
8010335c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010335f:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
80103364:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103367:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = dev;
8010336c:	8b 45 08             	mov    0x8(%ebp),%eax
8010336f:	a3 c4 32 11 80       	mov    %eax,0x801132c4
  recover_from_log();
80103374:	e8 b2 01 00 00       	call   8010352b <recover_from_log>
}
80103379:	90                   	nop
8010337a:	c9                   	leave  
8010337b:	c3                   	ret    

8010337c <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
8010337c:	55                   	push   %ebp
8010337d:	89 e5                	mov    %esp,%ebp
8010337f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103382:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103389:	e9 95 00 00 00       	jmp    80103423 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010338e:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
80103394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103397:	01 d0                	add    %edx,%eax
80103399:	83 c0 01             	add    $0x1,%eax
8010339c:	89 c2                	mov    %eax,%edx
8010339e:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033a3:	83 ec 08             	sub    $0x8,%esp
801033a6:	52                   	push   %edx
801033a7:	50                   	push   %eax
801033a8:	e8 09 ce ff ff       	call   801001b6 <bread>
801033ad:	83 c4 10             	add    $0x10,%esp
801033b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033b6:	83 c0 10             	add    $0x10,%eax
801033b9:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801033c0:	89 c2                	mov    %eax,%edx
801033c2:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033c7:	83 ec 08             	sub    $0x8,%esp
801033ca:	52                   	push   %edx
801033cb:	50                   	push   %eax
801033cc:	e8 e5 cd ff ff       	call   801001b6 <bread>
801033d1:	83 c4 10             	add    $0x10,%esp
801033d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033da:	8d 50 18             	lea    0x18(%eax),%edx
801033dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e0:	83 c0 18             	add    $0x18,%eax
801033e3:	83 ec 04             	sub    $0x4,%esp
801033e6:	68 00 02 00 00       	push   $0x200
801033eb:	52                   	push   %edx
801033ec:	50                   	push   %eax
801033ed:	e8 ce 22 00 00       	call   801056c0 <memmove>
801033f2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033f5:	83 ec 0c             	sub    $0xc,%esp
801033f8:	ff 75 ec             	pushl  -0x14(%ebp)
801033fb:	e8 ef cd ff ff       	call   801001ef <bwrite>
80103400:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103403:	83 ec 0c             	sub    $0xc,%esp
80103406:	ff 75 f0             	pushl  -0x10(%ebp)
80103409:	e8 20 ce ff ff       	call   8010022e <brelse>
8010340e:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103411:	83 ec 0c             	sub    $0xc,%esp
80103414:	ff 75 ec             	pushl  -0x14(%ebp)
80103417:	e8 12 ce ff ff       	call   8010022e <brelse>
8010341c:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010341f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103423:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103428:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010342b:	0f 8f 5d ff ff ff    	jg     8010338e <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103431:	90                   	nop
80103432:	c9                   	leave  
80103433:	c3                   	ret    

80103434 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103434:	55                   	push   %ebp
80103435:	89 e5                	mov    %esp,%ebp
80103437:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010343a:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010343f:	89 c2                	mov    %eax,%edx
80103441:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103446:	83 ec 08             	sub    $0x8,%esp
80103449:	52                   	push   %edx
8010344a:	50                   	push   %eax
8010344b:	e8 66 cd ff ff       	call   801001b6 <bread>
80103450:	83 c4 10             	add    $0x10,%esp
80103453:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103456:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103459:	83 c0 18             	add    $0x18,%eax
8010345c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010345f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103462:	8b 00                	mov    (%eax),%eax
80103464:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
80103469:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103470:	eb 1b                	jmp    8010348d <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103475:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103478:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010347c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010347f:	83 c2 10             	add    $0x10,%edx
80103482:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103489:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010348d:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103492:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103495:	7f db                	jg     80103472 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103497:	83 ec 0c             	sub    $0xc,%esp
8010349a:	ff 75 f0             	pushl  -0x10(%ebp)
8010349d:	e8 8c cd ff ff       	call   8010022e <brelse>
801034a2:	83 c4 10             	add    $0x10,%esp
}
801034a5:	90                   	nop
801034a6:	c9                   	leave  
801034a7:	c3                   	ret    

801034a8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034a8:	55                   	push   %ebp
801034a9:	89 e5                	mov    %esp,%ebp
801034ab:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ae:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801034b3:	89 c2                	mov    %eax,%edx
801034b5:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801034ba:	83 ec 08             	sub    $0x8,%esp
801034bd:	52                   	push   %edx
801034be:	50                   	push   %eax
801034bf:	e8 f2 cc ff ff       	call   801001b6 <bread>
801034c4:	83 c4 10             	add    $0x10,%esp
801034c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034cd:	83 c0 18             	add    $0x18,%eax
801034d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034d3:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034de:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034e5:	eb 1b                	jmp    80103502 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034ea:	83 c0 10             	add    $0x10,%eax
801034ed:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
801034f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034fa:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103502:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103507:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010350a:	7f db                	jg     801034e7 <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010350c:	83 ec 0c             	sub    $0xc,%esp
8010350f:	ff 75 f0             	pushl  -0x10(%ebp)
80103512:	e8 d8 cc ff ff       	call   801001ef <bwrite>
80103517:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010351a:	83 ec 0c             	sub    $0xc,%esp
8010351d:	ff 75 f0             	pushl  -0x10(%ebp)
80103520:	e8 09 cd ff ff       	call   8010022e <brelse>
80103525:	83 c4 10             	add    $0x10,%esp
}
80103528:	90                   	nop
80103529:	c9                   	leave  
8010352a:	c3                   	ret    

8010352b <recover_from_log>:

static void
recover_from_log(void)
{
8010352b:	55                   	push   %ebp
8010352c:	89 e5                	mov    %esp,%ebp
8010352e:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103531:	e8 fe fe ff ff       	call   80103434 <read_head>
  install_trans(); // if committed, copy from log to disk
80103536:	e8 41 fe ff ff       	call   8010337c <install_trans>
  log.lh.n = 0;
8010353b:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
80103542:	00 00 00 
  write_head(); // clear the log
80103545:	e8 5e ff ff ff       	call   801034a8 <write_head>
}
8010354a:	90                   	nop
8010354b:	c9                   	leave  
8010354c:	c3                   	ret    

8010354d <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010354d:	55                   	push   %ebp
8010354e:	89 e5                	mov    %esp,%ebp
80103550:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103553:	83 ec 0c             	sub    $0xc,%esp
80103556:	68 80 32 11 80       	push   $0x80113280
8010355b:	e8 3e 1e 00 00       	call   8010539e <acquire>
80103560:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103563:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103568:	85 c0                	test   %eax,%eax
8010356a:	74 17                	je     80103583 <begin_op+0x36>
      sleep(&log, &log.lock);
8010356c:	83 ec 08             	sub    $0x8,%esp
8010356f:	68 80 32 11 80       	push   $0x80113280
80103574:	68 80 32 11 80       	push   $0x80113280
80103579:	e8 7f 18 00 00       	call   80104dfd <sleep>
8010357e:	83 c4 10             	add    $0x10,%esp
80103581:	eb e0                	jmp    80103563 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103583:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
80103589:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010358e:	8d 50 01             	lea    0x1(%eax),%edx
80103591:	89 d0                	mov    %edx,%eax
80103593:	c1 e0 02             	shl    $0x2,%eax
80103596:	01 d0                	add    %edx,%eax
80103598:	01 c0                	add    %eax,%eax
8010359a:	01 c8                	add    %ecx,%eax
8010359c:	83 f8 1e             	cmp    $0x1e,%eax
8010359f:	7e 17                	jle    801035b8 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035a1:	83 ec 08             	sub    $0x8,%esp
801035a4:	68 80 32 11 80       	push   $0x80113280
801035a9:	68 80 32 11 80       	push   $0x80113280
801035ae:	e8 4a 18 00 00       	call   80104dfd <sleep>
801035b3:	83 c4 10             	add    $0x10,%esp
801035b6:	eb ab                	jmp    80103563 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035b8:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801035bd:	83 c0 01             	add    $0x1,%eax
801035c0:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
801035c5:	83 ec 0c             	sub    $0xc,%esp
801035c8:	68 80 32 11 80       	push   $0x80113280
801035cd:	e8 33 1e 00 00       	call   80105405 <release>
801035d2:	83 c4 10             	add    $0x10,%esp
      break;
801035d5:	90                   	nop
    }
  }
}
801035d6:	90                   	nop
801035d7:	c9                   	leave  
801035d8:	c3                   	ret    

801035d9 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035d9:	55                   	push   %ebp
801035da:	89 e5                	mov    %esp,%ebp
801035dc:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035e6:	83 ec 0c             	sub    $0xc,%esp
801035e9:	68 80 32 11 80       	push   $0x80113280
801035ee:	e8 ab 1d 00 00       	call   8010539e <acquire>
801035f3:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035f6:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801035fb:	83 e8 01             	sub    $0x1,%eax
801035fe:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
80103603:	a1 c0 32 11 80       	mov    0x801132c0,%eax
80103608:	85 c0                	test   %eax,%eax
8010360a:	74 0d                	je     80103619 <end_op+0x40>
    panic("log.committing");
8010360c:	83 ec 0c             	sub    $0xc,%esp
8010360f:	68 a4 8c 10 80       	push   $0x80108ca4
80103614:	e8 4d cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103619:	a1 bc 32 11 80       	mov    0x801132bc,%eax
8010361e:	85 c0                	test   %eax,%eax
80103620:	75 13                	jne    80103635 <end_op+0x5c>
    do_commit = 1;
80103622:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103629:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
80103630:	00 00 00 
80103633:	eb 10                	jmp    80103645 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 80 32 11 80       	push   $0x80113280
8010363d:	e8 a2 18 00 00       	call   80104ee4 <wakeup>
80103642:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103645:	83 ec 0c             	sub    $0xc,%esp
80103648:	68 80 32 11 80       	push   $0x80113280
8010364d:	e8 b3 1d 00 00       	call   80105405 <release>
80103652:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103659:	74 3f                	je     8010369a <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010365b:	e8 f5 00 00 00       	call   80103755 <commit>
    acquire(&log.lock);
80103660:	83 ec 0c             	sub    $0xc,%esp
80103663:	68 80 32 11 80       	push   $0x80113280
80103668:	e8 31 1d 00 00       	call   8010539e <acquire>
8010366d:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103670:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
80103677:	00 00 00 
    wakeup(&log);
8010367a:	83 ec 0c             	sub    $0xc,%esp
8010367d:	68 80 32 11 80       	push   $0x80113280
80103682:	e8 5d 18 00 00       	call   80104ee4 <wakeup>
80103687:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010368a:	83 ec 0c             	sub    $0xc,%esp
8010368d:	68 80 32 11 80       	push   $0x80113280
80103692:	e8 6e 1d 00 00       	call   80105405 <release>
80103697:	83 c4 10             	add    $0x10,%esp
  }
}
8010369a:	90                   	nop
8010369b:	c9                   	leave  
8010369c:	c3                   	ret    

8010369d <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
8010369d:	55                   	push   %ebp
8010369e:	89 e5                	mov    %esp,%ebp
801036a0:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036aa:	e9 95 00 00 00       	jmp    80103744 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036af:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
801036b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036b8:	01 d0                	add    %edx,%eax
801036ba:	83 c0 01             	add    $0x1,%eax
801036bd:	89 c2                	mov    %eax,%edx
801036bf:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801036c4:	83 ec 08             	sub    $0x8,%esp
801036c7:	52                   	push   %edx
801036c8:	50                   	push   %eax
801036c9:	e8 e8 ca ff ff       	call   801001b6 <bread>
801036ce:	83 c4 10             	add    $0x10,%esp
801036d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036d7:	83 c0 10             	add    $0x10,%eax
801036da:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801036e1:	89 c2                	mov    %eax,%edx
801036e3:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801036e8:	83 ec 08             	sub    $0x8,%esp
801036eb:	52                   	push   %edx
801036ec:	50                   	push   %eax
801036ed:	e8 c4 ca ff ff       	call   801001b6 <bread>
801036f2:	83 c4 10             	add    $0x10,%esp
801036f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036fb:	8d 50 18             	lea    0x18(%eax),%edx
801036fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103701:	83 c0 18             	add    $0x18,%eax
80103704:	83 ec 04             	sub    $0x4,%esp
80103707:	68 00 02 00 00       	push   $0x200
8010370c:	52                   	push   %edx
8010370d:	50                   	push   %eax
8010370e:	e8 ad 1f 00 00       	call   801056c0 <memmove>
80103713:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103716:	83 ec 0c             	sub    $0xc,%esp
80103719:	ff 75 f0             	pushl  -0x10(%ebp)
8010371c:	e8 ce ca ff ff       	call   801001ef <bwrite>
80103721:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103724:	83 ec 0c             	sub    $0xc,%esp
80103727:	ff 75 ec             	pushl  -0x14(%ebp)
8010372a:	e8 ff ca ff ff       	call   8010022e <brelse>
8010372f:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103732:	83 ec 0c             	sub    $0xc,%esp
80103735:	ff 75 f0             	pushl  -0x10(%ebp)
80103738:	e8 f1 ca ff ff       	call   8010022e <brelse>
8010373d:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103740:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103744:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103749:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010374c:	0f 8f 5d ff ff ff    	jg     801036af <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103752:	90                   	nop
80103753:	c9                   	leave  
80103754:	c3                   	ret    

80103755 <commit>:

static void
commit()
{
80103755:	55                   	push   %ebp
80103756:	89 e5                	mov    %esp,%ebp
80103758:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010375b:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103760:	85 c0                	test   %eax,%eax
80103762:	7e 1e                	jle    80103782 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103764:	e8 34 ff ff ff       	call   8010369d <write_log>
    write_head();    // Write header to disk -- the real commit
80103769:	e8 3a fd ff ff       	call   801034a8 <write_head>
    install_trans(); // Now install writes to home locations
8010376e:	e8 09 fc ff ff       	call   8010337c <install_trans>
    log.lh.n = 0; 
80103773:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
8010377a:	00 00 00 
    write_head();    // Erase the transaction from the log
8010377d:	e8 26 fd ff ff       	call   801034a8 <write_head>
  }
}
80103782:	90                   	nop
80103783:	c9                   	leave  
80103784:	c3                   	ret    

80103785 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103785:	55                   	push   %ebp
80103786:	89 e5                	mov    %esp,%ebp
80103788:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010378b:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103790:	83 f8 1d             	cmp    $0x1d,%eax
80103793:	7f 12                	jg     801037a7 <log_write+0x22>
80103795:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010379a:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
801037a0:	83 ea 01             	sub    $0x1,%edx
801037a3:	39 d0                	cmp    %edx,%eax
801037a5:	7c 0d                	jl     801037b4 <log_write+0x2f>
    panic("too big a transaction");
801037a7:	83 ec 0c             	sub    $0xc,%esp
801037aa:	68 b3 8c 10 80       	push   $0x80108cb3
801037af:	e8 b2 cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
801037b4:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801037b9:	85 c0                	test   %eax,%eax
801037bb:	7f 0d                	jg     801037ca <log_write+0x45>
    panic("log_write outside of trans");
801037bd:	83 ec 0c             	sub    $0xc,%esp
801037c0:	68 c9 8c 10 80       	push   $0x80108cc9
801037c5:	e8 9c cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
801037ca:	83 ec 0c             	sub    $0xc,%esp
801037cd:	68 80 32 11 80       	push   $0x80113280
801037d2:	e8 c7 1b 00 00       	call   8010539e <acquire>
801037d7:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037e1:	eb 1d                	jmp    80103800 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e6:	83 c0 10             	add    $0x10,%eax
801037e9:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
801037f0:	89 c2                	mov    %eax,%edx
801037f2:	8b 45 08             	mov    0x8(%ebp),%eax
801037f5:	8b 40 08             	mov    0x8(%eax),%eax
801037f8:	39 c2                	cmp    %eax,%edx
801037fa:	74 10                	je     8010380c <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103800:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103805:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103808:	7f d9                	jg     801037e3 <log_write+0x5e>
8010380a:	eb 01                	jmp    8010380d <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
8010380c:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 40 08             	mov    0x8(%eax),%eax
80103813:	89 c2                	mov    %eax,%edx
80103815:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103818:	83 c0 10             	add    $0x10,%eax
8010381b:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
80103822:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103827:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010382a:	75 0d                	jne    80103839 <log_write+0xb4>
    log.lh.n++;
8010382c:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103831:	83 c0 01             	add    $0x1,%eax
80103834:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
80103839:	8b 45 08             	mov    0x8(%ebp),%eax
8010383c:	8b 00                	mov    (%eax),%eax
8010383e:	83 c8 04             	or     $0x4,%eax
80103841:	89 c2                	mov    %eax,%edx
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103848:	83 ec 0c             	sub    $0xc,%esp
8010384b:	68 80 32 11 80       	push   $0x80113280
80103850:	e8 b0 1b 00 00       	call   80105405 <release>
80103855:	83 c4 10             	add    $0x10,%esp
}
80103858:	90                   	nop
80103859:	c9                   	leave  
8010385a:	c3                   	ret    

8010385b <v2p>:
8010385b:	55                   	push   %ebp
8010385c:	89 e5                	mov    %esp,%ebp
8010385e:	8b 45 08             	mov    0x8(%ebp),%eax
80103861:	05 00 00 00 80       	add    $0x80000000,%eax
80103866:	5d                   	pop    %ebp
80103867:	c3                   	ret    

80103868 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103868:	55                   	push   %ebp
80103869:	89 e5                	mov    %esp,%ebp
8010386b:	8b 45 08             	mov    0x8(%ebp),%eax
8010386e:	05 00 00 00 80       	add    $0x80000000,%eax
80103873:	5d                   	pop    %ebp
80103874:	c3                   	ret    

80103875 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103875:	55                   	push   %ebp
80103876:	89 e5                	mov    %esp,%ebp
80103878:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010387b:	8b 55 08             	mov    0x8(%ebp),%edx
8010387e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103881:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103884:	f0 87 02             	lock xchg %eax,(%edx)
80103887:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010388a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010388d:	c9                   	leave  
8010388e:	c3                   	ret    

8010388f <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010388f:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103893:	83 e4 f0             	and    $0xfffffff0,%esp
80103896:	ff 71 fc             	pushl  -0x4(%ecx)
80103899:	55                   	push   %ebp
8010389a:	89 e5                	mov    %esp,%ebp
8010389c:	51                   	push   %ecx
8010389d:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038a0:	83 ec 08             	sub    $0x8,%esp
801038a3:	68 00 00 40 80       	push   $0x80400000
801038a8:	68 1c 66 11 80       	push   $0x8011661c
801038ad:	e8 7d f2 ff ff       	call   80102b2f <kinit1>
801038b2:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038b5:	e8 f7 49 00 00       	call   801082b1 <kvmalloc>
  mpinit();        // collect info about this machine
801038ba:	e8 43 04 00 00       	call   80103d02 <mpinit>
  lapicinit();
801038bf:	e8 ea f5 ff ff       	call   80102eae <lapicinit>
  seginit();       // set up segments
801038c4:	e8 91 43 00 00       	call   80107c5a <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038c9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038cf:	0f b6 00             	movzbl (%eax),%eax
801038d2:	0f b6 c0             	movzbl %al,%eax
801038d5:	83 ec 08             	sub    $0x8,%esp
801038d8:	50                   	push   %eax
801038d9:	68 e4 8c 10 80       	push   $0x80108ce4
801038de:	e8 e3 ca ff ff       	call   801003c6 <cprintf>
801038e3:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038e6:	e8 6d 06 00 00       	call   80103f58 <picinit>
  ioapicinit();    // another interrupt controller
801038eb:	e8 34 f1 ff ff       	call   80102a24 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038f0:	e8 24 d2 ff ff       	call   80100b19 <consoleinit>
  uartinit();      // serial port
801038f5:	e8 bc 36 00 00       	call   80106fb6 <uartinit>
  pinit();         // process table
801038fa:	e8 5d 0b 00 00       	call   8010445c <pinit>
  tvinit();        // trap vectors
801038ff:	e8 8b 32 00 00       	call   80106b8f <tvinit>
  binit();         // buffer cache
80103904:	e8 2b c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103909:	e8 67 d6 ff ff       	call   80100f75 <fileinit>
  ideinit();       // disk
8010390e:	e8 19 ed ff ff       	call   8010262c <ideinit>
  if(!ismp)
80103913:	a1 64 33 11 80       	mov    0x80113364,%eax
80103918:	85 c0                	test   %eax,%eax
8010391a:	75 05                	jne    80103921 <main+0x92>
    timerinit();   // uniprocessor timer
8010391c:	e8 bf 31 00 00       	call   80106ae0 <timerinit>
  startothers();   // start other processors
80103921:	e8 7f 00 00 00       	call   801039a5 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103926:	83 ec 08             	sub    $0x8,%esp
80103929:	68 00 00 00 8e       	push   $0x8e000000
8010392e:	68 00 00 40 80       	push   $0x80400000
80103933:	e8 30 f2 ff ff       	call   80102b68 <kinit2>
80103938:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010393b:	e8 6e 0c 00 00       	call   801045ae <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103940:	e8 1a 00 00 00       	call   8010395f <mpmain>

80103945 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103945:	55                   	push   %ebp
80103946:	89 e5                	mov    %esp,%ebp
80103948:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
8010394b:	e8 79 49 00 00       	call   801082c9 <switchkvm>
  seginit();
80103950:	e8 05 43 00 00       	call   80107c5a <seginit>
  lapicinit();
80103955:	e8 54 f5 ff ff       	call   80102eae <lapicinit>
  mpmain();
8010395a:	e8 00 00 00 00       	call   8010395f <mpmain>

8010395f <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010395f:	55                   	push   %ebp
80103960:	89 e5                	mov    %esp,%ebp
80103962:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
80103965:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010396b:	0f b6 00             	movzbl (%eax),%eax
8010396e:	0f b6 c0             	movzbl %al,%eax
80103971:	83 ec 08             	sub    $0x8,%esp
80103974:	50                   	push   %eax
80103975:	68 fb 8c 10 80       	push   $0x80108cfb
8010397a:	e8 47 ca ff ff       	call   801003c6 <cprintf>
8010397f:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103982:	e8 69 33 00 00       	call   80106cf0 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103987:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010398d:	05 a8 00 00 00       	add    $0xa8,%eax
80103992:	83 ec 08             	sub    $0x8,%esp
80103995:	6a 01                	push   $0x1
80103997:	50                   	push   %eax
80103998:	e8 d8 fe ff ff       	call   80103875 <xchg>
8010399d:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039a0:	e8 08 12 00 00       	call   80104bad <scheduler>

801039a5 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039a5:	55                   	push   %ebp
801039a6:	89 e5                	mov    %esp,%ebp
801039a8:	53                   	push   %ebx
801039a9:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039ac:	68 00 70 00 00       	push   $0x7000
801039b1:	e8 b2 fe ff ff       	call   80103868 <p2v>
801039b6:	83 c4 04             	add    $0x4,%esp
801039b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039bc:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039c1:	83 ec 04             	sub    $0x4,%esp
801039c4:	50                   	push   %eax
801039c5:	68 2c c5 10 80       	push   $0x8010c52c
801039ca:	ff 75 f0             	pushl  -0x10(%ebp)
801039cd:	e8 ee 1c 00 00       	call   801056c0 <memmove>
801039d2:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039d5:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
801039dc:	e9 90 00 00 00       	jmp    80103a71 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801039e1:	e8 e6 f5 ff ff       	call   80102fcc <cpunum>
801039e6:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039ec:	05 80 33 11 80       	add    $0x80113380,%eax
801039f1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f4:	74 73                	je     80103a69 <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039f6:	e8 6b f2 ff ff       	call   80102c66 <kalloc>
801039fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a01:	83 e8 04             	sub    $0x4,%eax
80103a04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a07:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a0d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a12:	83 e8 08             	sub    $0x8,%eax
80103a15:	c7 00 45 39 10 80    	movl   $0x80103945,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1e:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 00 b0 10 80       	push   $0x8010b000
80103a29:	e8 2d fe ff ff       	call   8010385b <v2p>
80103a2e:	83 c4 10             	add    $0x10,%esp
80103a31:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a33:	83 ec 0c             	sub    $0xc,%esp
80103a36:	ff 75 f0             	pushl  -0x10(%ebp)
80103a39:	e8 1d fe ff ff       	call   8010385b <v2p>
80103a3e:	83 c4 10             	add    $0x10,%esp
80103a41:	89 c2                	mov    %eax,%edx
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	0f b6 00             	movzbl (%eax),%eax
80103a49:	0f b6 c0             	movzbl %al,%eax
80103a4c:	83 ec 08             	sub    $0x8,%esp
80103a4f:	52                   	push   %edx
80103a50:	50                   	push   %eax
80103a51:	e8 f0 f5 ff ff       	call   80103046 <lapicstartap>
80103a56:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a59:	90                   	nop
80103a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a5d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a63:	85 c0                	test   %eax,%eax
80103a65:	74 f3                	je     80103a5a <startothers+0xb5>
80103a67:	eb 01                	jmp    80103a6a <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a69:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a6a:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a71:	a1 60 39 11 80       	mov    0x80113960,%eax
80103a76:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a7c:	05 80 33 11 80       	add    $0x80113380,%eax
80103a81:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a84:	0f 87 57 ff ff ff    	ja     801039e1 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a8a:	90                   	nop
80103a8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a8e:	c9                   	leave  
80103a8f:	c3                   	ret    

80103a90 <p2v>:
80103a90:	55                   	push   %ebp
80103a91:	89 e5                	mov    %esp,%ebp
80103a93:	8b 45 08             	mov    0x8(%ebp),%eax
80103a96:	05 00 00 00 80       	add    $0x80000000,%eax
80103a9b:	5d                   	pop    %ebp
80103a9c:	c3                   	ret    

80103a9d <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80103a9d:	55                   	push   %ebp
80103a9e:	89 e5                	mov    %esp,%ebp
80103aa0:	83 ec 14             	sub    $0x14,%esp
80103aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80103aa6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103aaa:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103aae:	89 c2                	mov    %eax,%edx
80103ab0:	ec                   	in     (%dx),%al
80103ab1:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ab4:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103ab8:	c9                   	leave  
80103ab9:	c3                   	ret    

80103aba <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103aba:	55                   	push   %ebp
80103abb:	89 e5                	mov    %esp,%ebp
80103abd:	83 ec 08             	sub    $0x8,%esp
80103ac0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ac6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aca:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103acd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ad1:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ad5:	ee                   	out    %al,(%dx)
}
80103ad6:	90                   	nop
80103ad7:	c9                   	leave  
80103ad8:	c3                   	ret    

80103ad9 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ad9:	55                   	push   %ebp
80103ada:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103adc:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103ae1:	89 c2                	mov    %eax,%edx
80103ae3:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103ae8:	29 c2                	sub    %eax,%edx
80103aea:	89 d0                	mov    %edx,%eax
80103aec:	c1 f8 02             	sar    $0x2,%eax
80103aef:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103af5:	5d                   	pop    %ebp
80103af6:	c3                   	ret    

80103af7 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103af7:	55                   	push   %ebp
80103af8:	89 e5                	mov    %esp,%ebp
80103afa:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103afd:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b04:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b0b:	eb 15                	jmp    80103b22 <sum+0x2b>
    sum += addr[i];
80103b0d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b10:	8b 45 08             	mov    0x8(%ebp),%eax
80103b13:	01 d0                	add    %edx,%eax
80103b15:	0f b6 00             	movzbl (%eax),%eax
80103b18:	0f b6 c0             	movzbl %al,%eax
80103b1b:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b1e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b25:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b28:	7c e3                	jl     80103b0d <sum+0x16>
    sum += addr[i];
  return sum;
80103b2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b2d:	c9                   	leave  
80103b2e:	c3                   	ret    

80103b2f <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b2f:	55                   	push   %ebp
80103b30:	89 e5                	mov    %esp,%ebp
80103b32:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b35:	ff 75 08             	pushl  0x8(%ebp)
80103b38:	e8 53 ff ff ff       	call   80103a90 <p2v>
80103b3d:	83 c4 04             	add    $0x4,%esp
80103b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b43:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b49:	01 d0                	add    %edx,%eax
80103b4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b51:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b54:	eb 36                	jmp    80103b8c <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b56:	83 ec 04             	sub    $0x4,%esp
80103b59:	6a 04                	push   $0x4
80103b5b:	68 0c 8d 10 80       	push   $0x80108d0c
80103b60:	ff 75 f4             	pushl  -0xc(%ebp)
80103b63:	e8 00 1b 00 00       	call   80105668 <memcmp>
80103b68:	83 c4 10             	add    $0x10,%esp
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	75 19                	jne    80103b88 <mpsearch1+0x59>
80103b6f:	83 ec 08             	sub    $0x8,%esp
80103b72:	6a 10                	push   $0x10
80103b74:	ff 75 f4             	pushl  -0xc(%ebp)
80103b77:	e8 7b ff ff ff       	call   80103af7 <sum>
80103b7c:	83 c4 10             	add    $0x10,%esp
80103b7f:	84 c0                	test   %al,%al
80103b81:	75 05                	jne    80103b88 <mpsearch1+0x59>
      return (struct mp*)p;
80103b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b86:	eb 11                	jmp    80103b99 <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b88:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b92:	72 c2                	jb     80103b56 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b99:	c9                   	leave  
80103b9a:	c3                   	ret    

80103b9b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b9b:	55                   	push   %ebp
80103b9c:	89 e5                	mov    %esp,%ebp
80103b9e:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ba1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bab:	83 c0 0f             	add    $0xf,%eax
80103bae:	0f b6 00             	movzbl (%eax),%eax
80103bb1:	0f b6 c0             	movzbl %al,%eax
80103bb4:	c1 e0 08             	shl    $0x8,%eax
80103bb7:	89 c2                	mov    %eax,%edx
80103bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbc:	83 c0 0e             	add    $0xe,%eax
80103bbf:	0f b6 00             	movzbl (%eax),%eax
80103bc2:	0f b6 c0             	movzbl %al,%eax
80103bc5:	09 d0                	or     %edx,%eax
80103bc7:	c1 e0 04             	shl    $0x4,%eax
80103bca:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bcd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bd1:	74 21                	je     80103bf4 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bd3:	83 ec 08             	sub    $0x8,%esp
80103bd6:	68 00 04 00 00       	push   $0x400
80103bdb:	ff 75 f0             	pushl  -0x10(%ebp)
80103bde:	e8 4c ff ff ff       	call   80103b2f <mpsearch1>
80103be3:	83 c4 10             	add    $0x10,%esp
80103be6:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103be9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bed:	74 51                	je     80103c40 <mpsearch+0xa5>
      return mp;
80103bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf2:	eb 61                	jmp    80103c55 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf7:	83 c0 14             	add    $0x14,%eax
80103bfa:	0f b6 00             	movzbl (%eax),%eax
80103bfd:	0f b6 c0             	movzbl %al,%eax
80103c00:	c1 e0 08             	shl    $0x8,%eax
80103c03:	89 c2                	mov    %eax,%edx
80103c05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c08:	83 c0 13             	add    $0x13,%eax
80103c0b:	0f b6 00             	movzbl (%eax),%eax
80103c0e:	0f b6 c0             	movzbl %al,%eax
80103c11:	09 d0                	or     %edx,%eax
80103c13:	c1 e0 0a             	shl    $0xa,%eax
80103c16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1c:	2d 00 04 00 00       	sub    $0x400,%eax
80103c21:	83 ec 08             	sub    $0x8,%esp
80103c24:	68 00 04 00 00       	push   $0x400
80103c29:	50                   	push   %eax
80103c2a:	e8 00 ff ff ff       	call   80103b2f <mpsearch1>
80103c2f:	83 c4 10             	add    $0x10,%esp
80103c32:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c35:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c39:	74 05                	je     80103c40 <mpsearch+0xa5>
      return mp;
80103c3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3e:	eb 15                	jmp    80103c55 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c40:	83 ec 08             	sub    $0x8,%esp
80103c43:	68 00 00 01 00       	push   $0x10000
80103c48:	68 00 00 0f 00       	push   $0xf0000
80103c4d:	e8 dd fe ff ff       	call   80103b2f <mpsearch1>
80103c52:	83 c4 10             	add    $0x10,%esp
}
80103c55:	c9                   	leave  
80103c56:	c3                   	ret    

80103c57 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c57:	55                   	push   %ebp
80103c58:	89 e5                	mov    %esp,%ebp
80103c5a:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c5d:	e8 39 ff ff ff       	call   80103b9b <mpsearch>
80103c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c69:	74 0a                	je     80103c75 <mpconfig+0x1e>
80103c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6e:	8b 40 04             	mov    0x4(%eax),%eax
80103c71:	85 c0                	test   %eax,%eax
80103c73:	75 0a                	jne    80103c7f <mpconfig+0x28>
    return 0;
80103c75:	b8 00 00 00 00       	mov    $0x0,%eax
80103c7a:	e9 81 00 00 00       	jmp    80103d00 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c82:	8b 40 04             	mov    0x4(%eax),%eax
80103c85:	83 ec 0c             	sub    $0xc,%esp
80103c88:	50                   	push   %eax
80103c89:	e8 02 fe ff ff       	call   80103a90 <p2v>
80103c8e:	83 c4 10             	add    $0x10,%esp
80103c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c94:	83 ec 04             	sub    $0x4,%esp
80103c97:	6a 04                	push   $0x4
80103c99:	68 11 8d 10 80       	push   $0x80108d11
80103c9e:	ff 75 f0             	pushl  -0x10(%ebp)
80103ca1:	e8 c2 19 00 00       	call   80105668 <memcmp>
80103ca6:	83 c4 10             	add    $0x10,%esp
80103ca9:	85 c0                	test   %eax,%eax
80103cab:	74 07                	je     80103cb4 <mpconfig+0x5d>
    return 0;
80103cad:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb2:	eb 4c                	jmp    80103d00 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cbb:	3c 01                	cmp    $0x1,%al
80103cbd:	74 12                	je     80103cd1 <mpconfig+0x7a>
80103cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc2:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cc6:	3c 04                	cmp    $0x4,%al
80103cc8:	74 07                	je     80103cd1 <mpconfig+0x7a>
    return 0;
80103cca:	b8 00 00 00 00       	mov    $0x0,%eax
80103ccf:	eb 2f                	jmp    80103d00 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd4:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cd8:	0f b7 c0             	movzwl %ax,%eax
80103cdb:	83 ec 08             	sub    $0x8,%esp
80103cde:	50                   	push   %eax
80103cdf:	ff 75 f0             	pushl  -0x10(%ebp)
80103ce2:	e8 10 fe ff ff       	call   80103af7 <sum>
80103ce7:	83 c4 10             	add    $0x10,%esp
80103cea:	84 c0                	test   %al,%al
80103cec:	74 07                	je     80103cf5 <mpconfig+0x9e>
    return 0;
80103cee:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf3:	eb 0b                	jmp    80103d00 <mpconfig+0xa9>
  *pmp = mp;
80103cf5:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfb:	89 10                	mov    %edx,(%eax)
  return conf;
80103cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d00:	c9                   	leave  
80103d01:	c3                   	ret    

80103d02 <mpinit>:

void
mpinit(void)
{
80103d02:	55                   	push   %ebp
80103d03:	89 e5                	mov    %esp,%ebp
80103d05:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d08:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103d0f:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d12:	83 ec 0c             	sub    $0xc,%esp
80103d15:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d18:	50                   	push   %eax
80103d19:	e8 39 ff ff ff       	call   80103c57 <mpconfig>
80103d1e:	83 c4 10             	add    $0x10,%esp
80103d21:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d24:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d28:	0f 84 96 01 00 00    	je     80103ec4 <mpinit+0x1c2>
    return;
  ismp = 1;
80103d2e:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103d35:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3b:	8b 40 24             	mov    0x24(%eax),%eax
80103d3e:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d46:	83 c0 2c             	add    $0x2c,%eax
80103d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4f:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d53:	0f b7 d0             	movzwl %ax,%edx
80103d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d59:	01 d0                	add    %edx,%eax
80103d5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d5e:	e9 f2 00 00 00       	jmp    80103e55 <mpinit+0x153>
    switch(*p){
80103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d66:	0f b6 00             	movzbl (%eax),%eax
80103d69:	0f b6 c0             	movzbl %al,%eax
80103d6c:	83 f8 04             	cmp    $0x4,%eax
80103d6f:	0f 87 bc 00 00 00    	ja     80103e31 <mpinit+0x12f>
80103d75:	8b 04 85 54 8d 10 80 	mov    -0x7fef72ac(,%eax,4),%eax
80103d7c:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d81:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d84:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d87:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d8b:	0f b6 d0             	movzbl %al,%edx
80103d8e:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d93:	39 c2                	cmp    %eax,%edx
80103d95:	74 2b                	je     80103dc2 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d97:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d9a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d9e:	0f b6 d0             	movzbl %al,%edx
80103da1:	a1 60 39 11 80       	mov    0x80113960,%eax
80103da6:	83 ec 04             	sub    $0x4,%esp
80103da9:	52                   	push   %edx
80103daa:	50                   	push   %eax
80103dab:	68 16 8d 10 80       	push   $0x80108d16
80103db0:	e8 11 c6 ff ff       	call   801003c6 <cprintf>
80103db5:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103db8:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103dbf:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103dc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103dc5:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dc9:	0f b6 c0             	movzbl %al,%eax
80103dcc:	83 e0 02             	and    $0x2,%eax
80103dcf:	85 c0                	test   %eax,%eax
80103dd1:	74 15                	je     80103de8 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103dd3:	a1 60 39 11 80       	mov    0x80113960,%eax
80103dd8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dde:	05 80 33 11 80       	add    $0x80113380,%eax
80103de3:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103de8:	a1 60 39 11 80       	mov    0x80113960,%eax
80103ded:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103df3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103df9:	05 80 33 11 80       	add    $0x80113380,%eax
80103dfe:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e00:	a1 60 39 11 80       	mov    0x80113960,%eax
80103e05:	83 c0 01             	add    $0x1,%eax
80103e08:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103e0d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e11:	eb 42                	jmp    80103e55 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e16:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103e19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e1c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e20:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103e25:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e29:	eb 2a                	jmp    80103e55 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e2b:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e2f:	eb 24                	jmp    80103e55 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e34:	0f b6 00             	movzbl (%eax),%eax
80103e37:	0f b6 c0             	movzbl %al,%eax
80103e3a:	83 ec 08             	sub    $0x8,%esp
80103e3d:	50                   	push   %eax
80103e3e:	68 34 8d 10 80       	push   $0x80108d34
80103e43:	e8 7e c5 ff ff       	call   801003c6 <cprintf>
80103e48:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e4b:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103e52:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e58:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e5b:	0f 82 02 ff ff ff    	jb     80103d63 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e61:	a1 64 33 11 80       	mov    0x80113364,%eax
80103e66:	85 c0                	test   %eax,%eax
80103e68:	75 1d                	jne    80103e87 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e6a:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103e71:	00 00 00 
    lapic = 0;
80103e74:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103e7b:	00 00 00 
    ioapicid = 0;
80103e7e:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103e85:	eb 3e                	jmp    80103ec5 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e8a:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e8e:	84 c0                	test   %al,%al
80103e90:	74 33                	je     80103ec5 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e92:	83 ec 08             	sub    $0x8,%esp
80103e95:	6a 70                	push   $0x70
80103e97:	6a 22                	push   $0x22
80103e99:	e8 1c fc ff ff       	call   80103aba <outb>
80103e9e:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ea1:	83 ec 0c             	sub    $0xc,%esp
80103ea4:	6a 23                	push   $0x23
80103ea6:	e8 f2 fb ff ff       	call   80103a9d <inb>
80103eab:	83 c4 10             	add    $0x10,%esp
80103eae:	83 c8 01             	or     $0x1,%eax
80103eb1:	0f b6 c0             	movzbl %al,%eax
80103eb4:	83 ec 08             	sub    $0x8,%esp
80103eb7:	50                   	push   %eax
80103eb8:	6a 23                	push   $0x23
80103eba:	e8 fb fb ff ff       	call   80103aba <outb>
80103ebf:	83 c4 10             	add    $0x10,%esp
80103ec2:	eb 01                	jmp    80103ec5 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103ec4:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103ec5:	c9                   	leave  
80103ec6:	c3                   	ret    

80103ec7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ec7:	55                   	push   %ebp
80103ec8:	89 e5                	mov    %esp,%ebp
80103eca:	83 ec 08             	sub    $0x8,%esp
80103ecd:	8b 55 08             	mov    0x8(%ebp),%edx
80103ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ed7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103eda:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ede:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ee2:	ee                   	out    %al,(%dx)
}
80103ee3:	90                   	nop
80103ee4:	c9                   	leave  
80103ee5:	c3                   	ret    

80103ee6 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ee6:	55                   	push   %ebp
80103ee7:	89 e5                	mov    %esp,%ebp
80103ee9:	83 ec 04             	sub    $0x4,%esp
80103eec:	8b 45 08             	mov    0x8(%ebp),%eax
80103eef:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ef3:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ef7:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103efd:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f01:	0f b6 c0             	movzbl %al,%eax
80103f04:	50                   	push   %eax
80103f05:	6a 21                	push   $0x21
80103f07:	e8 bb ff ff ff       	call   80103ec7 <outb>
80103f0c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f0f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f13:	66 c1 e8 08          	shr    $0x8,%ax
80103f17:	0f b6 c0             	movzbl %al,%eax
80103f1a:	50                   	push   %eax
80103f1b:	68 a1 00 00 00       	push   $0xa1
80103f20:	e8 a2 ff ff ff       	call   80103ec7 <outb>
80103f25:	83 c4 08             	add    $0x8,%esp
}
80103f28:	90                   	nop
80103f29:	c9                   	leave  
80103f2a:	c3                   	ret    

80103f2b <picenable>:

void
picenable(int irq)
{
80103f2b:	55                   	push   %ebp
80103f2c:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f31:	ba 01 00 00 00       	mov    $0x1,%edx
80103f36:	89 c1                	mov    %eax,%ecx
80103f38:	d3 e2                	shl    %cl,%edx
80103f3a:	89 d0                	mov    %edx,%eax
80103f3c:	f7 d0                	not    %eax
80103f3e:	89 c2                	mov    %eax,%edx
80103f40:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f47:	21 d0                	and    %edx,%eax
80103f49:	0f b7 c0             	movzwl %ax,%eax
80103f4c:	50                   	push   %eax
80103f4d:	e8 94 ff ff ff       	call   80103ee6 <picsetmask>
80103f52:	83 c4 04             	add    $0x4,%esp
}
80103f55:	90                   	nop
80103f56:	c9                   	leave  
80103f57:	c3                   	ret    

80103f58 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f58:	55                   	push   %ebp
80103f59:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f5b:	68 ff 00 00 00       	push   $0xff
80103f60:	6a 21                	push   $0x21
80103f62:	e8 60 ff ff ff       	call   80103ec7 <outb>
80103f67:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f6a:	68 ff 00 00 00       	push   $0xff
80103f6f:	68 a1 00 00 00       	push   $0xa1
80103f74:	e8 4e ff ff ff       	call   80103ec7 <outb>
80103f79:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f7c:	6a 11                	push   $0x11
80103f7e:	6a 20                	push   $0x20
80103f80:	e8 42 ff ff ff       	call   80103ec7 <outb>
80103f85:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f88:	6a 20                	push   $0x20
80103f8a:	6a 21                	push   $0x21
80103f8c:	e8 36 ff ff ff       	call   80103ec7 <outb>
80103f91:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f94:	6a 04                	push   $0x4
80103f96:	6a 21                	push   $0x21
80103f98:	e8 2a ff ff ff       	call   80103ec7 <outb>
80103f9d:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fa0:	6a 03                	push   $0x3
80103fa2:	6a 21                	push   $0x21
80103fa4:	e8 1e ff ff ff       	call   80103ec7 <outb>
80103fa9:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fac:	6a 11                	push   $0x11
80103fae:	68 a0 00 00 00       	push   $0xa0
80103fb3:	e8 0f ff ff ff       	call   80103ec7 <outb>
80103fb8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fbb:	6a 28                	push   $0x28
80103fbd:	68 a1 00 00 00       	push   $0xa1
80103fc2:	e8 00 ff ff ff       	call   80103ec7 <outb>
80103fc7:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103fca:	6a 02                	push   $0x2
80103fcc:	68 a1 00 00 00       	push   $0xa1
80103fd1:	e8 f1 fe ff ff       	call   80103ec7 <outb>
80103fd6:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103fd9:	6a 03                	push   $0x3
80103fdb:	68 a1 00 00 00       	push   $0xa1
80103fe0:	e8 e2 fe ff ff       	call   80103ec7 <outb>
80103fe5:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103fe8:	6a 68                	push   $0x68
80103fea:	6a 20                	push   $0x20
80103fec:	e8 d6 fe ff ff       	call   80103ec7 <outb>
80103ff1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103ff4:	6a 0a                	push   $0xa
80103ff6:	6a 20                	push   $0x20
80103ff8:	e8 ca fe ff ff       	call   80103ec7 <outb>
80103ffd:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104000:	6a 68                	push   $0x68
80104002:	68 a0 00 00 00       	push   $0xa0
80104007:	e8 bb fe ff ff       	call   80103ec7 <outb>
8010400c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010400f:	6a 0a                	push   $0xa
80104011:	68 a0 00 00 00       	push   $0xa0
80104016:	e8 ac fe ff ff       	call   80103ec7 <outb>
8010401b:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010401e:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104025:	66 83 f8 ff          	cmp    $0xffff,%ax
80104029:	74 13                	je     8010403e <picinit+0xe6>
    picsetmask(irqmask);
8010402b:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80104032:	0f b7 c0             	movzwl %ax,%eax
80104035:	50                   	push   %eax
80104036:	e8 ab fe ff ff       	call   80103ee6 <picsetmask>
8010403b:	83 c4 04             	add    $0x4,%esp
}
8010403e:	90                   	nop
8010403f:	c9                   	leave  
80104040:	c3                   	ret    

80104041 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104041:	55                   	push   %ebp
80104042:	89 e5                	mov    %esp,%ebp
80104044:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80104047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010404e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104051:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104057:	8b 45 0c             	mov    0xc(%ebp),%eax
8010405a:	8b 10                	mov    (%eax),%edx
8010405c:	8b 45 08             	mov    0x8(%ebp),%eax
8010405f:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104061:	e8 2d cf ff ff       	call   80100f93 <filealloc>
80104066:	89 c2                	mov    %eax,%edx
80104068:	8b 45 08             	mov    0x8(%ebp),%eax
8010406b:	89 10                	mov    %edx,(%eax)
8010406d:	8b 45 08             	mov    0x8(%ebp),%eax
80104070:	8b 00                	mov    (%eax),%eax
80104072:	85 c0                	test   %eax,%eax
80104074:	0f 84 cb 00 00 00    	je     80104145 <pipealloc+0x104>
8010407a:	e8 14 cf ff ff       	call   80100f93 <filealloc>
8010407f:	89 c2                	mov    %eax,%edx
80104081:	8b 45 0c             	mov    0xc(%ebp),%eax
80104084:	89 10                	mov    %edx,(%eax)
80104086:	8b 45 0c             	mov    0xc(%ebp),%eax
80104089:	8b 00                	mov    (%eax),%eax
8010408b:	85 c0                	test   %eax,%eax
8010408d:	0f 84 b2 00 00 00    	je     80104145 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104093:	e8 ce eb ff ff       	call   80102c66 <kalloc>
80104098:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010409b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010409f:	0f 84 9f 00 00 00    	je     80104144 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
801040a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040af:	00 00 00 
  p->writeopen = 1;
801040b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040bc:	00 00 00 
  p->nwrite = 0;
801040bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040c9:	00 00 00 
  p->nread = 0;
801040cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040cf:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040d6:	00 00 00 
  initlock(&p->lock, "pipe");
801040d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040dc:	83 ec 08             	sub    $0x8,%esp
801040df:	68 68 8d 10 80       	push   $0x80108d68
801040e4:	50                   	push   %eax
801040e5:	e8 92 12 00 00       	call   8010537c <initlock>
801040ea:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040ed:	8b 45 08             	mov    0x8(%ebp),%eax
801040f0:	8b 00                	mov    (%eax),%eax
801040f2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040f8:	8b 45 08             	mov    0x8(%ebp),%eax
801040fb:	8b 00                	mov    (%eax),%eax
801040fd:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	8b 00                	mov    (%eax),%eax
80104106:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	8b 00                	mov    (%eax),%eax
8010410f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104112:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104115:	8b 45 0c             	mov    0xc(%ebp),%eax
80104118:	8b 00                	mov    (%eax),%eax
8010411a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104120:	8b 45 0c             	mov    0xc(%ebp),%eax
80104123:	8b 00                	mov    (%eax),%eax
80104125:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104129:	8b 45 0c             	mov    0xc(%ebp),%eax
8010412c:	8b 00                	mov    (%eax),%eax
8010412e:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104132:	8b 45 0c             	mov    0xc(%ebp),%eax
80104135:	8b 00                	mov    (%eax),%eax
80104137:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413a:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010413d:	b8 00 00 00 00       	mov    $0x0,%eax
80104142:	eb 4e                	jmp    80104192 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104144:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
80104145:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104149:	74 0e                	je     80104159 <pipealloc+0x118>
    kfree((char*)p);
8010414b:	83 ec 0c             	sub    $0xc,%esp
8010414e:	ff 75 f4             	pushl  -0xc(%ebp)
80104151:	e8 73 ea ff ff       	call   80102bc9 <kfree>
80104156:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104159:	8b 45 08             	mov    0x8(%ebp),%eax
8010415c:	8b 00                	mov    (%eax),%eax
8010415e:	85 c0                	test   %eax,%eax
80104160:	74 11                	je     80104173 <pipealloc+0x132>
    fileclose(*f0);
80104162:	8b 45 08             	mov    0x8(%ebp),%eax
80104165:	8b 00                	mov    (%eax),%eax
80104167:	83 ec 0c             	sub    $0xc,%esp
8010416a:	50                   	push   %eax
8010416b:	e8 e1 ce ff ff       	call   80101051 <fileclose>
80104170:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104173:	8b 45 0c             	mov    0xc(%ebp),%eax
80104176:	8b 00                	mov    (%eax),%eax
80104178:	85 c0                	test   %eax,%eax
8010417a:	74 11                	je     8010418d <pipealloc+0x14c>
    fileclose(*f1);
8010417c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417f:	8b 00                	mov    (%eax),%eax
80104181:	83 ec 0c             	sub    $0xc,%esp
80104184:	50                   	push   %eax
80104185:	e8 c7 ce ff ff       	call   80101051 <fileclose>
8010418a:	83 c4 10             	add    $0x10,%esp
  return -1;
8010418d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104192:	c9                   	leave  
80104193:	c3                   	ret    

80104194 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104194:	55                   	push   %ebp
80104195:	89 e5                	mov    %esp,%ebp
80104197:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	83 ec 0c             	sub    $0xc,%esp
801041a0:	50                   	push   %eax
801041a1:	e8 f8 11 00 00       	call   8010539e <acquire>
801041a6:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041ad:	74 23                	je     801041d2 <pipeclose+0x3e>
    p->writeopen = 0;
801041af:	8b 45 08             	mov    0x8(%ebp),%eax
801041b2:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041b9:	00 00 00 
    wakeup(&p->nread);
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	05 34 02 00 00       	add    $0x234,%eax
801041c4:	83 ec 0c             	sub    $0xc,%esp
801041c7:	50                   	push   %eax
801041c8:	e8 17 0d 00 00       	call   80104ee4 <wakeup>
801041cd:	83 c4 10             	add    $0x10,%esp
801041d0:	eb 21                	jmp    801041f3 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041d2:	8b 45 08             	mov    0x8(%ebp),%eax
801041d5:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041dc:	00 00 00 
    wakeup(&p->nwrite);
801041df:	8b 45 08             	mov    0x8(%ebp),%eax
801041e2:	05 38 02 00 00       	add    $0x238,%eax
801041e7:	83 ec 0c             	sub    $0xc,%esp
801041ea:	50                   	push   %eax
801041eb:	e8 f4 0c 00 00       	call   80104ee4 <wakeup>
801041f0:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041f3:	8b 45 08             	mov    0x8(%ebp),%eax
801041f6:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041fc:	85 c0                	test   %eax,%eax
801041fe:	75 2c                	jne    8010422c <pipeclose+0x98>
80104200:	8b 45 08             	mov    0x8(%ebp),%eax
80104203:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104209:	85 c0                	test   %eax,%eax
8010420b:	75 1f                	jne    8010422c <pipeclose+0x98>
    release(&p->lock);
8010420d:	8b 45 08             	mov    0x8(%ebp),%eax
80104210:	83 ec 0c             	sub    $0xc,%esp
80104213:	50                   	push   %eax
80104214:	e8 ec 11 00 00       	call   80105405 <release>
80104219:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	ff 75 08             	pushl  0x8(%ebp)
80104222:	e8 a2 e9 ff ff       	call   80102bc9 <kfree>
80104227:	83 c4 10             	add    $0x10,%esp
8010422a:	eb 0f                	jmp    8010423b <pipeclose+0xa7>
  } else
    release(&p->lock);
8010422c:	8b 45 08             	mov    0x8(%ebp),%eax
8010422f:	83 ec 0c             	sub    $0xc,%esp
80104232:	50                   	push   %eax
80104233:	e8 cd 11 00 00       	call   80105405 <release>
80104238:	83 c4 10             	add    $0x10,%esp
}
8010423b:	90                   	nop
8010423c:	c9                   	leave  
8010423d:	c3                   	ret    

8010423e <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010423e:	55                   	push   %ebp
8010423f:	89 e5                	mov    %esp,%ebp
80104241:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104244:	8b 45 08             	mov    0x8(%ebp),%eax
80104247:	83 ec 0c             	sub    $0xc,%esp
8010424a:	50                   	push   %eax
8010424b:	e8 4e 11 00 00       	call   8010539e <acquire>
80104250:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104253:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010425a:	e9 ad 00 00 00       	jmp    8010430c <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
8010425f:	8b 45 08             	mov    0x8(%ebp),%eax
80104262:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104268:	85 c0                	test   %eax,%eax
8010426a:	74 0d                	je     80104279 <pipewrite+0x3b>
8010426c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104272:	8b 40 24             	mov    0x24(%eax),%eax
80104275:	85 c0                	test   %eax,%eax
80104277:	74 19                	je     80104292 <pipewrite+0x54>
        release(&p->lock);
80104279:	8b 45 08             	mov    0x8(%ebp),%eax
8010427c:	83 ec 0c             	sub    $0xc,%esp
8010427f:	50                   	push   %eax
80104280:	e8 80 11 00 00       	call   80105405 <release>
80104285:	83 c4 10             	add    $0x10,%esp
        return -1;
80104288:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010428d:	e9 a8 00 00 00       	jmp    8010433a <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104292:	8b 45 08             	mov    0x8(%ebp),%eax
80104295:	05 34 02 00 00       	add    $0x234,%eax
8010429a:	83 ec 0c             	sub    $0xc,%esp
8010429d:	50                   	push   %eax
8010429e:	e8 41 0c 00 00       	call   80104ee4 <wakeup>
801042a3:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042a6:	8b 45 08             	mov    0x8(%ebp),%eax
801042a9:	8b 55 08             	mov    0x8(%ebp),%edx
801042ac:	81 c2 38 02 00 00    	add    $0x238,%edx
801042b2:	83 ec 08             	sub    $0x8,%esp
801042b5:	50                   	push   %eax
801042b6:	52                   	push   %edx
801042b7:	e8 41 0b 00 00       	call   80104dfd <sleep>
801042bc:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042c8:	8b 45 08             	mov    0x8(%ebp),%eax
801042cb:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042d1:	05 00 02 00 00       	add    $0x200,%eax
801042d6:	39 c2                	cmp    %eax,%edx
801042d8:	74 85                	je     8010425f <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042e3:	8d 48 01             	lea    0x1(%eax),%ecx
801042e6:	8b 55 08             	mov    0x8(%ebp),%edx
801042e9:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042ef:	25 ff 01 00 00       	and    $0x1ff,%eax
801042f4:	89 c1                	mov    %eax,%ecx
801042f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801042fc:	01 d0                	add    %edx,%eax
801042fe:	0f b6 10             	movzbl (%eax),%edx
80104301:	8b 45 08             	mov    0x8(%ebp),%eax
80104304:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104308:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	3b 45 10             	cmp    0x10(%ebp),%eax
80104312:	7c ab                	jl     801042bf <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104314:	8b 45 08             	mov    0x8(%ebp),%eax
80104317:	05 34 02 00 00       	add    $0x234,%eax
8010431c:	83 ec 0c             	sub    $0xc,%esp
8010431f:	50                   	push   %eax
80104320:	e8 bf 0b 00 00       	call   80104ee4 <wakeup>
80104325:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104328:	8b 45 08             	mov    0x8(%ebp),%eax
8010432b:	83 ec 0c             	sub    $0xc,%esp
8010432e:	50                   	push   %eax
8010432f:	e8 d1 10 00 00       	call   80105405 <release>
80104334:	83 c4 10             	add    $0x10,%esp
  return n;
80104337:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010433a:	c9                   	leave  
8010433b:	c3                   	ret    

8010433c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010433c:	55                   	push   %ebp
8010433d:	89 e5                	mov    %esp,%ebp
8010433f:	53                   	push   %ebx
80104340:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
80104346:	83 ec 0c             	sub    $0xc,%esp
80104349:	50                   	push   %eax
8010434a:	e8 4f 10 00 00       	call   8010539e <acquire>
8010434f:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104352:	eb 3f                	jmp    80104393 <piperead+0x57>
    if(proc->killed){
80104354:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010435a:	8b 40 24             	mov    0x24(%eax),%eax
8010435d:	85 c0                	test   %eax,%eax
8010435f:	74 19                	je     8010437a <piperead+0x3e>
      release(&p->lock);
80104361:	8b 45 08             	mov    0x8(%ebp),%eax
80104364:	83 ec 0c             	sub    $0xc,%esp
80104367:	50                   	push   %eax
80104368:	e8 98 10 00 00       	call   80105405 <release>
8010436d:	83 c4 10             	add    $0x10,%esp
      return -1;
80104370:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104375:	e9 bf 00 00 00       	jmp    80104439 <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010437a:	8b 45 08             	mov    0x8(%ebp),%eax
8010437d:	8b 55 08             	mov    0x8(%ebp),%edx
80104380:	81 c2 34 02 00 00    	add    $0x234,%edx
80104386:	83 ec 08             	sub    $0x8,%esp
80104389:	50                   	push   %eax
8010438a:	52                   	push   %edx
8010438b:	e8 6d 0a 00 00       	call   80104dfd <sleep>
80104390:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104393:	8b 45 08             	mov    0x8(%ebp),%eax
80104396:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439c:	8b 45 08             	mov    0x8(%ebp),%eax
8010439f:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a5:	39 c2                	cmp    %eax,%edx
801043a7:	75 0d                	jne    801043b6 <piperead+0x7a>
801043a9:	8b 45 08             	mov    0x8(%ebp),%eax
801043ac:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b2:	85 c0                	test   %eax,%eax
801043b4:	75 9e                	jne    80104354 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043bd:	eb 49                	jmp    80104408 <piperead+0xcc>
    if(p->nread == p->nwrite)
801043bf:	8b 45 08             	mov    0x8(%ebp),%eax
801043c2:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c8:	8b 45 08             	mov    0x8(%ebp),%eax
801043cb:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d1:	39 c2                	cmp    %eax,%edx
801043d3:	74 3d                	je     80104412 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801043db:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043de:	8b 45 08             	mov    0x8(%ebp),%eax
801043e1:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043e7:	8d 48 01             	lea    0x1(%eax),%ecx
801043ea:	8b 55 08             	mov    0x8(%ebp),%edx
801043ed:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043f3:	25 ff 01 00 00       	and    $0x1ff,%eax
801043f8:	89 c2                	mov    %eax,%edx
801043fa:	8b 45 08             	mov    0x8(%ebp),%eax
801043fd:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104402:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104404:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010440e:	7c af                	jl     801043bf <piperead+0x83>
80104410:	eb 01                	jmp    80104413 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104412:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	05 38 02 00 00       	add    $0x238,%eax
8010441b:	83 ec 0c             	sub    $0xc,%esp
8010441e:	50                   	push   %eax
8010441f:	e8 c0 0a 00 00       	call   80104ee4 <wakeup>
80104424:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104427:	8b 45 08             	mov    0x8(%ebp),%eax
8010442a:	83 ec 0c             	sub    $0xc,%esp
8010442d:	50                   	push   %eax
8010442e:	e8 d2 0f 00 00       	call   80105405 <release>
80104433:	83 c4 10             	add    $0x10,%esp
  return i;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010443c:	c9                   	leave  
8010443d:	c3                   	ret    

8010443e <hlt>:
}

// hlt() added by Noah Zentzis, Fall 2016.
static inline void
hlt()
{
8010443e:	55                   	push   %ebp
8010443f:	89 e5                	mov    %esp,%ebp
  asm volatile("hlt");
80104441:	f4                   	hlt    
}
80104442:	90                   	nop
80104443:	5d                   	pop    %ebp
80104444:	c3                   	ret    

80104445 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104445:	55                   	push   %ebp
80104446:	89 e5                	mov    %esp,%ebp
80104448:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010444b:	9c                   	pushf  
8010444c:	58                   	pop    %eax
8010444d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104450:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104453:	c9                   	leave  
80104454:	c3                   	ret    

80104455 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104455:	55                   	push   %ebp
80104456:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104458:	fb                   	sti    
}
80104459:	90                   	nop
8010445a:	5d                   	pop    %ebp
8010445b:	c3                   	ret    

8010445c <pinit>:
static int stateListRemove(struct proc** head, struct proc** tail, struct proc* p);
#endif

void
pinit(void)
{
8010445c:	55                   	push   %ebp
8010445d:	89 e5                	mov    %esp,%ebp
8010445f:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104462:	83 ec 08             	sub    $0x8,%esp
80104465:	68 70 8d 10 80       	push   $0x80108d70
8010446a:	68 80 39 11 80       	push   $0x80113980
8010446f:	e8 08 0f 00 00       	call   8010537c <initlock>
80104474:	83 c4 10             	add    $0x10,%esp
}
80104477:	90                   	nop
80104478:	c9                   	leave  
80104479:	c3                   	ret    

8010447a <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010447a:	55                   	push   %ebp
8010447b:	89 e5                	mov    %esp,%ebp
8010447d:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104480:	83 ec 0c             	sub    $0xc,%esp
80104483:	68 80 39 11 80       	push   $0x80113980
80104488:	e8 11 0f 00 00       	call   8010539e <acquire>
8010448d:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104490:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104497:	eb 11                	jmp    801044aa <allocproc+0x30>
    if(p->state == UNUSED)
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	8b 40 0c             	mov    0xc(%eax),%eax
8010449f:	85 c0                	test   %eax,%eax
801044a1:	74 2a                	je     801044cd <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044a3:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
801044aa:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
801044b1:	72 e6                	jb     80104499 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
801044b3:	83 ec 0c             	sub    $0xc,%esp
801044b6:	68 80 39 11 80       	push   $0x80113980
801044bb:	e8 45 0f 00 00       	call   80105405 <release>
801044c0:	83 c4 10             	add    $0x10,%esp
  return 0;
801044c3:	b8 00 00 00 00       	mov    $0x0,%eax
801044c8:	e9 df 00 00 00       	jmp    801045ac <allocproc+0x132>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801044cd:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d1:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044d8:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801044dd:	8d 50 01             	lea    0x1(%eax),%edx
801044e0:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
801044e6:	89 c2                	mov    %eax,%edx
801044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044eb:	89 50 10             	mov    %edx,0x10(%eax)
  release(&ptable.lock);
801044ee:	83 ec 0c             	sub    $0xc,%esp
801044f1:	68 80 39 11 80       	push   $0x80113980
801044f6:	e8 0a 0f 00 00       	call   80105405 <release>
801044fb:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801044fe:	e8 63 e7 ff ff       	call   80102c66 <kalloc>
80104503:	89 c2                	mov    %eax,%edx
80104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104508:	89 50 08             	mov    %edx,0x8(%eax)
8010450b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450e:	8b 40 08             	mov    0x8(%eax),%eax
80104511:	85 c0                	test   %eax,%eax
80104513:	75 14                	jne    80104529 <allocproc+0xaf>
    p->state = UNUSED;
80104515:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104518:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010451f:	b8 00 00 00 00       	mov    $0x0,%eax
80104524:	e9 83 00 00 00       	jmp    801045ac <allocproc+0x132>
  }
  sp = p->kstack + KSTACKSIZE;
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452c:	8b 40 08             	mov    0x8(%eax),%eax
8010452f:	05 00 10 00 00       	add    $0x1000,%eax
80104534:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104537:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104541:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104544:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104548:	ba 3d 6b 10 80       	mov    $0x80106b3d,%edx
8010454d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104550:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104552:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104556:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104559:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010455c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010455f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104562:	8b 40 1c             	mov    0x1c(%eax),%eax
80104565:	83 ec 04             	sub    $0x4,%esp
80104568:	6a 14                	push   $0x14
8010456a:	6a 00                	push   $0x0
8010456c:	50                   	push   %eax
8010456d:	e8 8f 10 00 00       	call   80105601 <memset>
80104572:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104578:	8b 40 1c             	mov    0x1c(%eax),%eax
8010457b:	ba b7 4d 10 80       	mov    $0x80104db7,%edx
80104580:	89 50 10             	mov    %edx,0x10(%eax)

//student added
  #ifdef CS333_P1
  p->start_ticks = ticks;
80104583:	8b 15 c0 65 11 80    	mov    0x801165c0,%edx
80104589:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458c:	89 50 7c             	mov    %edx,0x7c(%eax)
  #endif
  #ifdef CS333_P2
  p->cpu_ticks_total = 0;
8010458f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104592:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104599:	00 00 00 
  p->cpu_ticks_in = 0;
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459f:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
801045a6:	00 00 00 
  #endif

  return p;
801045a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045ac:	c9                   	leave  
801045ad:	c3                   	ret    

801045ae <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045ae:	55                   	push   %ebp
801045af:	89 e5                	mov    %esp,%ebp
801045b1:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801045b4:	e8 c1 fe ff ff       	call   8010447a <allocproc>
801045b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045bf:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
801045c4:	e8 36 3c 00 00       	call   801081ff <setupkvm>
801045c9:	89 c2                	mov    %eax,%edx
801045cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ce:	89 50 04             	mov    %edx,0x4(%eax)
801045d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d4:	8b 40 04             	mov    0x4(%eax),%eax
801045d7:	85 c0                	test   %eax,%eax
801045d9:	75 0d                	jne    801045e8 <userinit+0x3a>
    panic("userinit: out of memory?");
801045db:	83 ec 0c             	sub    $0xc,%esp
801045de:	68 77 8d 10 80       	push   $0x80108d77
801045e3:	e8 7e bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045e8:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f0:	8b 40 04             	mov    0x4(%eax),%eax
801045f3:	83 ec 04             	sub    $0x4,%esp
801045f6:	52                   	push   %edx
801045f7:	68 00 c5 10 80       	push   $0x8010c500
801045fc:	50                   	push   %eax
801045fd:	e8 57 3e 00 00       	call   80108459 <inituvm>
80104602:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104605:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104608:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104611:	8b 40 18             	mov    0x18(%eax),%eax
80104614:	83 ec 04             	sub    $0x4,%esp
80104617:	6a 4c                	push   $0x4c
80104619:	6a 00                	push   $0x0
8010461b:	50                   	push   %eax
8010461c:	e8 e0 0f 00 00       	call   80105601 <memset>
80104621:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104624:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104627:	8b 40 18             	mov    0x18(%eax),%eax
8010462a:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104633:	8b 40 18             	mov    0x18(%eax),%eax
80104636:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010463c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463f:	8b 40 18             	mov    0x18(%eax),%eax
80104642:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104645:	8b 52 18             	mov    0x18(%edx),%edx
80104648:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010464c:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	8b 40 18             	mov    0x18(%eax),%eax
80104656:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104659:	8b 52 18             	mov    0x18(%edx),%edx
8010465c:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104660:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104664:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104667:	8b 40 18             	mov    0x18(%eax),%eax
8010466a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104674:	8b 40 18             	mov    0x18(%eax),%eax
80104677:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010467e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104681:	8b 40 18             	mov    0x18(%eax),%eax
80104684:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010468b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468e:	83 c0 6c             	add    $0x6c,%eax
80104691:	83 ec 04             	sub    $0x4,%esp
80104694:	6a 10                	push   $0x10
80104696:	68 90 8d 10 80       	push   $0x80108d90
8010469b:	50                   	push   %eax
8010469c:	e8 63 11 00 00       	call   80105804 <safestrcpy>
801046a1:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046a4:	83 ec 0c             	sub    $0xc,%esp
801046a7:	68 99 8d 10 80       	push   $0x80108d99
801046ac:	e8 77 de ff ff       	call   80102528 <namei>
801046b1:	83 c4 10             	add    $0x10,%esp
801046b4:	89 c2                	mov    %eax,%edx
801046b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b9:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801046bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046bf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  #ifdef CS333_P2
  p->parent = 0;
801046c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c9:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  p->uid = DEFAULT_UID;
801046d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d3:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801046da:	00 00 00 
  p->gid = DEFAULT_GID;
801046dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e0:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
801046e7:	00 00 00 
  #endif
}
801046ea:	90                   	nop
801046eb:	c9                   	leave  
801046ec:	c3                   	ret    

801046ed <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046ed:	55                   	push   %ebp
801046ee:	89 e5                	mov    %esp,%ebp
801046f0:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
801046f3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046f9:	8b 00                	mov    (%eax),%eax
801046fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046fe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104702:	7e 31                	jle    80104735 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104704:	8b 55 08             	mov    0x8(%ebp),%edx
80104707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470a:	01 c2                	add    %eax,%edx
8010470c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104712:	8b 40 04             	mov    0x4(%eax),%eax
80104715:	83 ec 04             	sub    $0x4,%esp
80104718:	52                   	push   %edx
80104719:	ff 75 f4             	pushl  -0xc(%ebp)
8010471c:	50                   	push   %eax
8010471d:	e8 84 3e 00 00       	call   801085a6 <allocuvm>
80104722:	83 c4 10             	add    $0x10,%esp
80104725:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104728:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010472c:	75 3e                	jne    8010476c <growproc+0x7f>
      return -1;
8010472e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104733:	eb 59                	jmp    8010478e <growproc+0xa1>
  } else if(n < 0){
80104735:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104739:	79 31                	jns    8010476c <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010473b:	8b 55 08             	mov    0x8(%ebp),%edx
8010473e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104741:	01 c2                	add    %eax,%edx
80104743:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104749:	8b 40 04             	mov    0x4(%eax),%eax
8010474c:	83 ec 04             	sub    $0x4,%esp
8010474f:	52                   	push   %edx
80104750:	ff 75 f4             	pushl  -0xc(%ebp)
80104753:	50                   	push   %eax
80104754:	e8 16 3f 00 00       	call   8010866f <deallocuvm>
80104759:	83 c4 10             	add    $0x10,%esp
8010475c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010475f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104763:	75 07                	jne    8010476c <growproc+0x7f>
      return -1;
80104765:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476a:	eb 22                	jmp    8010478e <growproc+0xa1>
  }
  proc->sz = sz;
8010476c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104772:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104775:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477d:	83 ec 0c             	sub    $0xc,%esp
80104780:	50                   	push   %eax
80104781:	e8 60 3b 00 00       	call   801082e6 <switchuvm>
80104786:	83 c4 10             	add    $0x10,%esp
  return 0;
80104789:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010478e:	c9                   	leave  
8010478f:	c3                   	ret    

80104790 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104790:	55                   	push   %ebp
80104791:	89 e5                	mov    %esp,%ebp
80104793:	57                   	push   %edi
80104794:	56                   	push   %esi
80104795:	53                   	push   %ebx
80104796:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104799:	e8 dc fc ff ff       	call   8010447a <allocproc>
8010479e:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047a5:	75 0a                	jne    801047b1 <fork+0x21>
    return -1;
801047a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ac:	e9 92 01 00 00       	jmp    80104943 <fork+0x1b3>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801047b1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047b7:	8b 10                	mov    (%eax),%edx
801047b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047bf:	8b 40 04             	mov    0x4(%eax),%eax
801047c2:	83 ec 08             	sub    $0x8,%esp
801047c5:	52                   	push   %edx
801047c6:	50                   	push   %eax
801047c7:	e8 41 40 00 00       	call   8010880d <copyuvm>
801047cc:	83 c4 10             	add    $0x10,%esp
801047cf:	89 c2                	mov    %eax,%edx
801047d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d4:	89 50 04             	mov    %edx,0x4(%eax)
801047d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047da:	8b 40 04             	mov    0x4(%eax),%eax
801047dd:	85 c0                	test   %eax,%eax
801047df:	75 30                	jne    80104811 <fork+0x81>
    kfree(np->kstack);
801047e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e4:	8b 40 08             	mov    0x8(%eax),%eax
801047e7:	83 ec 0c             	sub    $0xc,%esp
801047ea:	50                   	push   %eax
801047eb:	e8 d9 e3 ff ff       	call   80102bc9 <kfree>
801047f0:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104800:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104807:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010480c:	e9 32 01 00 00       	jmp    80104943 <fork+0x1b3>
  }
  np->sz = proc->sz;
80104811:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104817:	8b 10                	mov    (%eax),%edx
80104819:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010481c:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010481e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104825:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104828:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010482b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482e:	8b 50 18             	mov    0x18(%eax),%edx
80104831:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104837:	8b 40 18             	mov    0x18(%eax),%eax
8010483a:	89 c3                	mov    %eax,%ebx
8010483c:	b8 13 00 00 00       	mov    $0x13,%eax
80104841:	89 d7                	mov    %edx,%edi
80104843:	89 de                	mov    %ebx,%esi
80104845:	89 c1                	mov    %eax,%ecx
80104847:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104849:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484c:	8b 40 18             	mov    0x18(%eax),%eax
8010484f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104856:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010485d:	eb 43                	jmp    801048a2 <fork+0x112>
    if(proc->ofile[i])
8010485f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104865:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104868:	83 c2 08             	add    $0x8,%edx
8010486b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010486f:	85 c0                	test   %eax,%eax
80104871:	74 2b                	je     8010489e <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104873:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104879:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010487c:	83 c2 08             	add    $0x8,%edx
8010487f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104883:	83 ec 0c             	sub    $0xc,%esp
80104886:	50                   	push   %eax
80104887:	e8 74 c7 ff ff       	call   80101000 <filedup>
8010488c:	83 c4 10             	add    $0x10,%esp
8010488f:	89 c1                	mov    %eax,%ecx
80104891:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104894:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104897:	83 c2 08             	add    $0x8,%edx
8010489a:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010489e:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801048a2:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048a6:	7e b7                	jle    8010485f <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
801048a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ae:	8b 40 68             	mov    0x68(%eax),%eax
801048b1:	83 ec 0c             	sub    $0xc,%esp
801048b4:	50                   	push   %eax
801048b5:	e8 76 d0 ff ff       	call   80101930 <idup>
801048ba:	83 c4 10             	add    $0x10,%esp
801048bd:	89 c2                	mov    %eax,%edx
801048bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c2:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048cb:	8d 50 6c             	lea    0x6c(%eax),%edx
801048ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d1:	83 c0 6c             	add    $0x6c,%eax
801048d4:	83 ec 04             	sub    $0x4,%esp
801048d7:	6a 10                	push   $0x10
801048d9:	52                   	push   %edx
801048da:	50                   	push   %eax
801048db:	e8 24 0f 00 00       	call   80105804 <safestrcpy>
801048e0:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
801048e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e6:	8b 40 10             	mov    0x10(%eax),%eax
801048e9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  #ifdef CS333_P2
  np->uid = proc->uid;
801048ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048f2:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801048f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048fb:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  np->gid = proc->gid;
80104901:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104907:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
8010490d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104910:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
  #endif

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104916:	83 ec 0c             	sub    $0xc,%esp
80104919:	68 80 39 11 80       	push   $0x80113980
8010491e:	e8 7b 0a 00 00       	call   8010539e <acquire>
80104923:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104926:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104929:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104930:	83 ec 0c             	sub    $0xc,%esp
80104933:	68 80 39 11 80       	push   $0x80113980
80104938:	e8 c8 0a 00 00       	call   80105405 <release>
8010493d:	83 c4 10             	add    $0x10,%esp

  return pid;
80104940:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104943:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104946:	5b                   	pop    %ebx
80104947:	5e                   	pop    %esi
80104948:	5f                   	pop    %edi
80104949:	5d                   	pop    %ebp
8010494a:	c3                   	ret    

8010494b <exit>:
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
#ifndef CS333_P3P4
void
exit(void)
{
8010494b:	55                   	push   %ebp
8010494c:	89 e5                	mov    %esp,%ebp
8010494e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104951:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104958:	a1 68 c6 10 80       	mov    0x8010c668,%eax
8010495d:	39 c2                	cmp    %eax,%edx
8010495f:	75 0d                	jne    8010496e <exit+0x23>
    panic("init exiting");
80104961:	83 ec 0c             	sub    $0xc,%esp
80104964:	68 9b 8d 10 80       	push   $0x80108d9b
80104969:	e8 f8 bb ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010496e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104975:	eb 48                	jmp    801049bf <exit+0x74>
    if(proc->ofile[fd]){
80104977:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010497d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104980:	83 c2 08             	add    $0x8,%edx
80104983:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104987:	85 c0                	test   %eax,%eax
80104989:	74 30                	je     801049bb <exit+0x70>
      fileclose(proc->ofile[fd]);
8010498b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104991:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104994:	83 c2 08             	add    $0x8,%edx
80104997:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010499b:	83 ec 0c             	sub    $0xc,%esp
8010499e:	50                   	push   %eax
8010499f:	e8 ad c6 ff ff       	call   80101051 <fileclose>
801049a4:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
801049a7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049b0:	83 c2 08             	add    $0x8,%edx
801049b3:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801049ba:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049bb:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801049bf:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801049c3:	7e b2                	jle    80104977 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
801049c5:	e8 83 eb ff ff       	call   8010354d <begin_op>
  iput(proc->cwd);
801049ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049d0:	8b 40 68             	mov    0x68(%eax),%eax
801049d3:	83 ec 0c             	sub    $0xc,%esp
801049d6:	50                   	push   %eax
801049d7:	e8 5e d1 ff ff       	call   80101b3a <iput>
801049dc:	83 c4 10             	add    $0x10,%esp
  end_op();
801049df:	e8 f5 eb ff ff       	call   801035d9 <end_op>
  proc->cwd = 0;
801049e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049ea:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049f1:	83 ec 0c             	sub    $0xc,%esp
801049f4:	68 80 39 11 80       	push   $0x80113980
801049f9:	e8 a0 09 00 00       	call   8010539e <acquire>
801049fe:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104a01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a07:	8b 40 14             	mov    0x14(%eax),%eax
80104a0a:	83 ec 0c             	sub    $0xc,%esp
80104a0d:	50                   	push   %eax
80104a0e:	e8 8f 04 00 00       	call   80104ea2 <wakeup1>
80104a13:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a16:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104a1d:	eb 3f                	jmp    80104a5e <exit+0x113>
    if(p->parent == proc){
80104a1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a22:	8b 50 14             	mov    0x14(%eax),%edx
80104a25:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a2b:	39 c2                	cmp    %eax,%edx
80104a2d:	75 28                	jne    80104a57 <exit+0x10c>
      p->parent = initproc;
80104a2f:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a38:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3e:	8b 40 0c             	mov    0xc(%eax),%eax
80104a41:	83 f8 05             	cmp    $0x5,%eax
80104a44:	75 11                	jne    80104a57 <exit+0x10c>
        wakeup1(initproc);
80104a46:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104a4b:	83 ec 0c             	sub    $0xc,%esp
80104a4e:	50                   	push   %eax
80104a4f:	e8 4e 04 00 00       	call   80104ea2 <wakeup1>
80104a54:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a57:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104a5e:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104a65:	72 b8                	jb     80104a1f <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a6d:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a74:	e8 11 02 00 00       	call   80104c8a <sched>
  panic("zombie exit");
80104a79:	83 ec 0c             	sub    $0xc,%esp
80104a7c:	68 a8 8d 10 80       	push   $0x80108da8
80104a81:	e8 e0 ba ff ff       	call   80100566 <panic>

80104a86 <wait>:
// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
#ifndef CS333_P3P4
int
wait(void)
{
80104a86:	55                   	push   %ebp
80104a87:	89 e5                	mov    %esp,%ebp
80104a89:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a8c:	83 ec 0c             	sub    $0xc,%esp
80104a8f:	68 80 39 11 80       	push   $0x80113980
80104a94:	e8 05 09 00 00       	call   8010539e <acquire>
80104a99:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa3:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104aaa:	e9 a9 00 00 00       	jmp    80104b58 <wait+0xd2>
      if(p->parent != proc)
80104aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab2:	8b 50 14             	mov    0x14(%eax),%edx
80104ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104abb:	39 c2                	cmp    %eax,%edx
80104abd:	0f 85 8d 00 00 00    	jne    80104b50 <wait+0xca>
        continue;
      havekids = 1;
80104ac3:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104acd:	8b 40 0c             	mov    0xc(%eax),%eax
80104ad0:	83 f8 05             	cmp    $0x5,%eax
80104ad3:	75 7c                	jne    80104b51 <wait+0xcb>
        // Found one.
        pid = p->pid;
80104ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad8:	8b 40 10             	mov    0x10(%eax),%eax
80104adb:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae1:	8b 40 08             	mov    0x8(%eax),%eax
80104ae4:	83 ec 0c             	sub    $0xc,%esp
80104ae7:	50                   	push   %eax
80104ae8:	e8 dc e0 ff ff       	call   80102bc9 <kfree>
80104aed:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104afd:	8b 40 04             	mov    0x4(%eax),%eax
80104b00:	83 ec 0c             	sub    $0xc,%esp
80104b03:	50                   	push   %eax
80104b04:	e8 23 3c 00 00       	call   8010872c <freevm>
80104b09:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b19:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b23:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b34:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b3b:	83 ec 0c             	sub    $0xc,%esp
80104b3e:	68 80 39 11 80       	push   $0x80113980
80104b43:	e8 bd 08 00 00       	call   80105405 <release>
80104b48:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b4e:	eb 5b                	jmp    80104bab <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b50:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b51:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104b58:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104b5f:	0f 82 4a ff ff ff    	jb     80104aaf <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b69:	74 0d                	je     80104b78 <wait+0xf2>
80104b6b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b71:	8b 40 24             	mov    0x24(%eax),%eax
80104b74:	85 c0                	test   %eax,%eax
80104b76:	74 17                	je     80104b8f <wait+0x109>
      release(&ptable.lock);
80104b78:	83 ec 0c             	sub    $0xc,%esp
80104b7b:	68 80 39 11 80       	push   $0x80113980
80104b80:	e8 80 08 00 00       	call   80105405 <release>
80104b85:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b8d:	eb 1c                	jmp    80104bab <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b95:	83 ec 08             	sub    $0x8,%esp
80104b98:	68 80 39 11 80       	push   $0x80113980
80104b9d:	50                   	push   %eax
80104b9e:	e8 5a 02 00 00       	call   80104dfd <sleep>
80104ba3:	83 c4 10             	add    $0x10,%esp
  }
80104ba6:	e9 f1 fe ff ff       	jmp    80104a9c <wait+0x16>
}
80104bab:	c9                   	leave  
80104bac:	c3                   	ret    

80104bad <scheduler>:
//      via swtch back to the scheduler.
#ifndef CS333_P3P4
// original xv6 scheduler. Use if CS333_P3P4 NOT defined.
void
scheduler(void)
{
80104bad:	55                   	push   %ebp
80104bae:	89 e5                	mov    %esp,%ebp
80104bb0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int idle;  // for checking if processor is idle

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104bb3:	e8 9d f8 ff ff       	call   80104455 <sti>

    idle = 1;  // assume idle unless we schedule a process
80104bb8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104bbf:	83 ec 0c             	sub    $0xc,%esp
80104bc2:	68 80 39 11 80       	push   $0x80113980
80104bc7:	e8 d2 07 00 00       	call   8010539e <acquire>
80104bcc:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bcf:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104bd6:	eb 7c                	jmp    80104c54 <scheduler+0xa7>
      if(p->state != RUNNABLE)
80104bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdb:	8b 40 0c             	mov    0xc(%eax),%eax
80104bde:	83 f8 03             	cmp    $0x3,%eax
80104be1:	75 69                	jne    80104c4c <scheduler+0x9f>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      idle = 0;  // not idle this timeslice
80104be3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      proc = p;
80104bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bed:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bf3:	83 ec 0c             	sub    $0xc,%esp
80104bf6:	ff 75 f4             	pushl  -0xc(%ebp)
80104bf9:	e8 e8 36 00 00       	call   801082e6 <switchuvm>
80104bfe:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c04:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      #ifdef CS333_P2
      p->cpu_ticks_in = ticks;
80104c0b:	8b 15 c0 65 11 80    	mov    0x801165c0,%edx
80104c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c14:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
      #endif
      swtch(&cpu->scheduler, proc->context);
80104c1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c20:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c23:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104c2a:	83 c2 04             	add    $0x4,%edx
80104c2d:	83 ec 08             	sub    $0x8,%esp
80104c30:	50                   	push   %eax
80104c31:	52                   	push   %edx
80104c32:	e8 3e 0c 00 00       	call   80105875 <swtch>
80104c37:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104c3a:	e8 8a 36 00 00       	call   801082c9 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c3f:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c46:	00 00 00 00 
80104c4a:	eb 01                	jmp    80104c4d <scheduler+0xa0>
    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104c4c:	90                   	nop
    sti();

    idle = 1;  // assume idle unless we schedule a process
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c4d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104c54:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104c5b:	0f 82 77 ff ff ff    	jb     80104bd8 <scheduler+0x2b>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104c61:	83 ec 0c             	sub    $0xc,%esp
80104c64:	68 80 39 11 80       	push   $0x80113980
80104c69:	e8 97 07 00 00       	call   80105405 <release>
80104c6e:	83 c4 10             	add    $0x10,%esp
    // if idle, wait for next interrupt
    if (idle) {
80104c71:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c75:	0f 84 38 ff ff ff    	je     80104bb3 <scheduler+0x6>
      sti();
80104c7b:	e8 d5 f7 ff ff       	call   80104455 <sti>
      hlt();
80104c80:	e8 b9 f7 ff ff       	call   8010443e <hlt>
    }
  }
80104c85:	e9 29 ff ff ff       	jmp    80104bb3 <scheduler+0x6>

80104c8a <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c8a:	55                   	push   %ebp
80104c8b:	89 e5                	mov    %esp,%ebp
80104c8d:	53                   	push   %ebx
80104c8e:	83 ec 14             	sub    $0x14,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c91:	83 ec 0c             	sub    $0xc,%esp
80104c94:	68 80 39 11 80       	push   $0x80113980
80104c99:	e8 33 08 00 00       	call   801054d1 <holding>
80104c9e:	83 c4 10             	add    $0x10,%esp
80104ca1:	85 c0                	test   %eax,%eax
80104ca3:	75 0d                	jne    80104cb2 <sched+0x28>
    panic("sched ptable.lock");
80104ca5:	83 ec 0c             	sub    $0xc,%esp
80104ca8:	68 b4 8d 10 80       	push   $0x80108db4
80104cad:	e8 b4 b8 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104cb2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cb8:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104cbe:	83 f8 01             	cmp    $0x1,%eax
80104cc1:	74 0d                	je     80104cd0 <sched+0x46>
    panic("sched locks");
80104cc3:	83 ec 0c             	sub    $0xc,%esp
80104cc6:	68 c6 8d 10 80       	push   $0x80108dc6
80104ccb:	e8 96 b8 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104cd0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cd6:	8b 40 0c             	mov    0xc(%eax),%eax
80104cd9:	83 f8 04             	cmp    $0x4,%eax
80104cdc:	75 0d                	jne    80104ceb <sched+0x61>
    panic("sched running");
80104cde:	83 ec 0c             	sub    $0xc,%esp
80104ce1:	68 d2 8d 10 80       	push   $0x80108dd2
80104ce6:	e8 7b b8 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104ceb:	e8 55 f7 ff ff       	call   80104445 <readeflags>
80104cf0:	25 00 02 00 00       	and    $0x200,%eax
80104cf5:	85 c0                	test   %eax,%eax
80104cf7:	74 0d                	je     80104d06 <sched+0x7c>
    panic("sched interruptible");
80104cf9:	83 ec 0c             	sub    $0xc,%esp
80104cfc:	68 e0 8d 10 80       	push   $0x80108de0
80104d01:	e8 60 b8 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104d06:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d0c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d12:	89 45 f4             	mov    %eax,-0xc(%ebp)
  #ifdef CS333_P2
  proc->cpu_ticks_total += ticks - proc->cpu_ticks_in;
80104d15:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d1b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d22:	8b 8a 88 00 00 00    	mov    0x88(%edx),%ecx
80104d28:	8b 1d c0 65 11 80    	mov    0x801165c0,%ebx
80104d2e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d35:	8b 92 8c 00 00 00    	mov    0x8c(%edx),%edx
80104d3b:	29 d3                	sub    %edx,%ebx
80104d3d:	89 da                	mov    %ebx,%edx
80104d3f:	01 ca                	add    %ecx,%edx
80104d41:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
  #endif
  swtch(&proc->context, cpu->scheduler);
80104d47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d4d:	8b 40 04             	mov    0x4(%eax),%eax
80104d50:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d57:	83 c2 1c             	add    $0x1c,%edx
80104d5a:	83 ec 08             	sub    $0x8,%esp
80104d5d:	50                   	push   %eax
80104d5e:	52                   	push   %edx
80104d5f:	e8 11 0b 00 00       	call   80105875 <swtch>
80104d64:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104d67:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d70:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d76:	90                   	nop
80104d77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d7a:	c9                   	leave  
80104d7b:	c3                   	ret    

80104d7c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d7c:	55                   	push   %ebp
80104d7d:	89 e5                	mov    %esp,%ebp
80104d7f:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d82:	83 ec 0c             	sub    $0xc,%esp
80104d85:	68 80 39 11 80       	push   $0x80113980
80104d8a:	e8 0f 06 00 00       	call   8010539e <acquire>
80104d8f:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104d92:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d98:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d9f:	e8 e6 fe ff ff       	call   80104c8a <sched>
  release(&ptable.lock);
80104da4:	83 ec 0c             	sub    $0xc,%esp
80104da7:	68 80 39 11 80       	push   $0x80113980
80104dac:	e8 54 06 00 00       	call   80105405 <release>
80104db1:	83 c4 10             	add    $0x10,%esp
}
80104db4:	90                   	nop
80104db5:	c9                   	leave  
80104db6:	c3                   	ret    

80104db7 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104db7:	55                   	push   %ebp
80104db8:	89 e5                	mov    %esp,%ebp
80104dba:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104dbd:	83 ec 0c             	sub    $0xc,%esp
80104dc0:	68 80 39 11 80       	push   $0x80113980
80104dc5:	e8 3b 06 00 00       	call   80105405 <release>
80104dca:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104dcd:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104dd2:	85 c0                	test   %eax,%eax
80104dd4:	74 24                	je     80104dfa <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104dd6:	c7 05 20 c0 10 80 00 	movl   $0x0,0x8010c020
80104ddd:	00 00 00 
    iinit(ROOTDEV);
80104de0:	83 ec 0c             	sub    $0xc,%esp
80104de3:	6a 01                	push   $0x1
80104de5:	e8 54 c8 ff ff       	call   8010163e <iinit>
80104dea:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104ded:	83 ec 0c             	sub    $0xc,%esp
80104df0:	6a 01                	push   $0x1
80104df2:	e8 38 e5 ff ff       	call   8010332f <initlog>
80104df7:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104dfa:	90                   	nop
80104dfb:	c9                   	leave  
80104dfc:	c3                   	ret    

80104dfd <sleep>:
// Reacquires lock when awakened.
// 2016/12/28: ticklock removed from xv6. sleep() changed to
// accept a NULL lock to accommodate.
void
sleep(void *chan, struct spinlock *lk)
{
80104dfd:	55                   	push   %ebp
80104dfe:	89 e5                	mov    %esp,%ebp
80104e00:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104e03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e09:	85 c0                	test   %eax,%eax
80104e0b:	75 0d                	jne    80104e1a <sleep+0x1d>
    panic("sleep");
80104e0d:	83 ec 0c             	sub    $0xc,%esp
80104e10:	68 f4 8d 10 80       	push   $0x80108df4
80104e15:	e8 4c b7 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){
80104e1a:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104e21:	74 24                	je     80104e47 <sleep+0x4a>
    acquire(&ptable.lock);
80104e23:	83 ec 0c             	sub    $0xc,%esp
80104e26:	68 80 39 11 80       	push   $0x80113980
80104e2b:	e8 6e 05 00 00       	call   8010539e <acquire>
80104e30:	83 c4 10             	add    $0x10,%esp
    if (lk) release(lk);
80104e33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e37:	74 0e                	je     80104e47 <sleep+0x4a>
80104e39:	83 ec 0c             	sub    $0xc,%esp
80104e3c:	ff 75 0c             	pushl  0xc(%ebp)
80104e3f:	e8 c1 05 00 00       	call   80105405 <release>
80104e44:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104e47:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e4d:	8b 55 08             	mov    0x8(%ebp),%edx
80104e50:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104e53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e59:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104e60:	e8 25 fe ff ff       	call   80104c8a <sched>

  // Tidy up.
  proc->chan = 0;
80104e65:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e6b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){
80104e72:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104e79:	74 24                	je     80104e9f <sleep+0xa2>
    release(&ptable.lock);
80104e7b:	83 ec 0c             	sub    $0xc,%esp
80104e7e:	68 80 39 11 80       	push   $0x80113980
80104e83:	e8 7d 05 00 00       	call   80105405 <release>
80104e88:	83 c4 10             	add    $0x10,%esp
    if (lk) acquire(lk);
80104e8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e8f:	74 0e                	je     80104e9f <sleep+0xa2>
80104e91:	83 ec 0c             	sub    $0xc,%esp
80104e94:	ff 75 0c             	pushl  0xc(%ebp)
80104e97:	e8 02 05 00 00       	call   8010539e <acquire>
80104e9c:	83 c4 10             	add    $0x10,%esp
  }
}
80104e9f:	90                   	nop
80104ea0:	c9                   	leave  
80104ea1:	c3                   	ret    

80104ea2 <wakeup1>:
#ifndef CS333_P3P4
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ea2:	55                   	push   %ebp
80104ea3:	89 e5                	mov    %esp,%ebp
80104ea5:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ea8:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80104eaf:	eb 27                	jmp    80104ed8 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104eb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eb4:	8b 40 0c             	mov    0xc(%eax),%eax
80104eb7:	83 f8 02             	cmp    $0x2,%eax
80104eba:	75 15                	jne    80104ed1 <wakeup1+0x2f>
80104ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ebf:	8b 40 20             	mov    0x20(%eax),%eax
80104ec2:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ec5:	75 0a                	jne    80104ed1 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104ec7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104eca:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ed1:	81 45 fc 90 00 00 00 	addl   $0x90,-0x4(%ebp)
80104ed8:	81 7d fc b4 5d 11 80 	cmpl   $0x80115db4,-0x4(%ebp)
80104edf:	72 d0                	jb     80104eb1 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104ee1:	90                   	nop
80104ee2:	c9                   	leave  
80104ee3:	c3                   	ret    

80104ee4 <wakeup>:
#endif

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ee4:	55                   	push   %ebp
80104ee5:	89 e5                	mov    %esp,%ebp
80104ee7:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104eea:	83 ec 0c             	sub    $0xc,%esp
80104eed:	68 80 39 11 80       	push   $0x80113980
80104ef2:	e8 a7 04 00 00       	call   8010539e <acquire>
80104ef7:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104efa:	83 ec 0c             	sub    $0xc,%esp
80104efd:	ff 75 08             	pushl  0x8(%ebp)
80104f00:	e8 9d ff ff ff       	call   80104ea2 <wakeup1>
80104f05:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f08:	83 ec 0c             	sub    $0xc,%esp
80104f0b:	68 80 39 11 80       	push   $0x80113980
80104f10:	e8 f0 04 00 00       	call   80105405 <release>
80104f15:	83 c4 10             	add    $0x10,%esp
}
80104f18:	90                   	nop
80104f19:	c9                   	leave  
80104f1a:	c3                   	ret    

80104f1b <kill>:
// Process won't exit until it returns
// to user space (see trap in trap.c).
#ifndef CS333_P3P4
int
kill(int pid)
{
80104f1b:	55                   	push   %ebp
80104f1c:	89 e5                	mov    %esp,%ebp
80104f1e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f21:	83 ec 0c             	sub    $0xc,%esp
80104f24:	68 80 39 11 80       	push   $0x80113980
80104f29:	e8 70 04 00 00       	call   8010539e <acquire>
80104f2e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f31:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104f38:	eb 4a                	jmp    80104f84 <kill+0x69>
    if(p->pid == pid){
80104f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3d:	8b 50 10             	mov    0x10(%eax),%edx
80104f40:	8b 45 08             	mov    0x8(%ebp),%eax
80104f43:	39 c2                	cmp    %eax,%edx
80104f45:	75 36                	jne    80104f7d <kill+0x62>
      p->killed = 1;
80104f47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f54:	8b 40 0c             	mov    0xc(%eax),%eax
80104f57:	83 f8 02             	cmp    $0x2,%eax
80104f5a:	75 0a                	jne    80104f66 <kill+0x4b>
        p->state = RUNNABLE;
80104f5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f66:	83 ec 0c             	sub    $0xc,%esp
80104f69:	68 80 39 11 80       	push   $0x80113980
80104f6e:	e8 92 04 00 00       	call   80105405 <release>
80104f73:	83 c4 10             	add    $0x10,%esp
      return 0;
80104f76:	b8 00 00 00 00       	mov    $0x0,%eax
80104f7b:	eb 25                	jmp    80104fa2 <kill+0x87>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f7d:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80104f84:	81 7d f4 b4 5d 11 80 	cmpl   $0x80115db4,-0xc(%ebp)
80104f8b:	72 ad                	jb     80104f3a <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f8d:	83 ec 0c             	sub    $0xc,%esp
80104f90:	68 80 39 11 80       	push   $0x80113980
80104f95:	e8 6b 04 00 00       	call   80105405 <release>
80104f9a:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104fa2:	c9                   	leave  
80104fa3:	c3                   	ret    

80104fa4 <print_millisec>:
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
#ifdef CS333_P1
void
print_millisec(uint millisec)
{
80104fa4:	55                   	push   %ebp
80104fa5:	89 e5                	mov    %esp,%ebp
80104fa7:	83 ec 08             	sub    $0x8,%esp
  cprintf("%d.", millisec /1000);
80104faa:	8b 45 08             	mov    0x8(%ebp),%eax
80104fad:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80104fb2:	f7 e2                	mul    %edx
80104fb4:	89 d0                	mov    %edx,%eax
80104fb6:	c1 e8 06             	shr    $0x6,%eax
80104fb9:	83 ec 08             	sub    $0x8,%esp
80104fbc:	50                   	push   %eax
80104fbd:	68 24 8e 10 80       	push   $0x80108e24
80104fc2:	e8 ff b3 ff ff       	call   801003c6 <cprintf>
80104fc7:	83 c4 10             	add    $0x10,%esp

  millisec %= 1000;
80104fca:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104fcd:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
80104fd2:	89 c8                	mov    %ecx,%eax
80104fd4:	f7 e2                	mul    %edx
80104fd6:	89 d0                	mov    %edx,%eax
80104fd8:	c1 e8 06             	shr    $0x6,%eax
80104fdb:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
80104fe1:	29 c1                	sub    %eax,%ecx
80104fe3:	89 c8                	mov    %ecx,%eax
80104fe5:	89 45 08             	mov    %eax,0x8(%ebp)
  if (millisec < 100)
80104fe8:	83 7d 08 63          	cmpl   $0x63,0x8(%ebp)
80104fec:	77 10                	ja     80104ffe <print_millisec+0x5a>
    cprintf("0");
80104fee:	83 ec 0c             	sub    $0xc,%esp
80104ff1:	68 28 8e 10 80       	push   $0x80108e28
80104ff6:	e8 cb b3 ff ff       	call   801003c6 <cprintf>
80104ffb:	83 c4 10             	add    $0x10,%esp
  if (millisec < 10)
80104ffe:	83 7d 08 09          	cmpl   $0x9,0x8(%ebp)
80105002:	77 10                	ja     80105014 <print_millisec+0x70>
    cprintf("0");
80105004:	83 ec 0c             	sub    $0xc,%esp
80105007:	68 28 8e 10 80       	push   $0x80108e28
8010500c:	e8 b5 b3 ff ff       	call   801003c6 <cprintf>
80105011:	83 c4 10             	add    $0x10,%esp

  cprintf("%d\t", millisec);
80105014:	83 ec 08             	sub    $0x8,%esp
80105017:	ff 75 08             	pushl  0x8(%ebp)
8010501a:	68 2a 8e 10 80       	push   $0x80108e2a
8010501f:	e8 a2 b3 ff ff       	call   801003c6 <cprintf>
80105024:	83 c4 10             	add    $0x10,%esp
}
80105027:	90                   	nop
80105028:	c9                   	leave  
80105029:	c3                   	ret    

8010502a <getprocs>:
#endif

#ifdef CS333_P2
int
getprocs(uint max, struct uproc* table)
{
8010502a:	55                   	push   %ebp
8010502b:	89 e5                	mov    %esp,%ebp
8010502d:	83 ec 18             	sub    $0x18,%esp
  int num_uprocs;
  struct proc* begin, * end;
  if (!table || max < 1)
80105030:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105034:	74 06                	je     8010503c <getprocs+0x12>
80105036:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010503a:	75 0a                	jne    80105046 <getprocs+0x1c>
    return -1;
8010503c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105041:	e9 6d 01 00 00       	jmp    801051b3 <getprocs+0x189>

  acquire(&ptable.lock);
80105046:	83 ec 0c             	sub    $0xc,%esp
80105049:	68 80 39 11 80       	push   $0x80113980
8010504e:	e8 4b 03 00 00       	call   8010539e <acquire>
80105053:	83 c4 10             	add    $0x10,%esp

  begin = ptable.proc;
80105056:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
  end = ptable.proc + NPROC;
8010505d:	c7 45 ec b4 5d 11 80 	movl   $0x80115db4,-0x14(%ebp)
  num_uprocs = 0;
80105064:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  while (begin < end && num_uprocs < max) {
8010506b:	e9 1c 01 00 00       	jmp    8010518c <getprocs+0x162>
    if (begin->state == EMBRYO || begin->state == UNUSED) {
80105070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105073:	8b 40 0c             	mov    0xc(%eax),%eax
80105076:	83 f8 01             	cmp    $0x1,%eax
80105079:	74 0a                	je     80105085 <getprocs+0x5b>
8010507b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507e:	8b 40 0c             	mov    0xc(%eax),%eax
80105081:	85 c0                	test   %eax,%eax
80105083:	75 0c                	jne    80105091 <getprocs+0x67>
      ++begin;
80105085:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
      continue;
8010508c:	e9 fb 00 00 00       	jmp    8010518c <getprocs+0x162>
    }
    table->pid = begin->pid;
80105091:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105094:	8b 50 10             	mov    0x10(%eax),%edx
80105097:	8b 45 0c             	mov    0xc(%ebp),%eax
8010509a:	89 10                	mov    %edx,(%eax)
    table->uid = begin->uid;
8010509c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509f:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801050a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801050a8:	89 50 04             	mov    %edx,0x4(%eax)
    table->gid = begin->gid;
801050ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050ae:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
801050b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801050b7:	89 50 08             	mov    %edx,0x8(%eax)
    table->ppid = (begin->parent) ? begin->parent->pid : begin->pid;
801050ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050bd:	8b 40 14             	mov    0x14(%eax),%eax
801050c0:	85 c0                	test   %eax,%eax
801050c2:	74 0b                	je     801050cf <getprocs+0xa5>
801050c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050c7:	8b 40 14             	mov    0x14(%eax),%eax
801050ca:	8b 40 10             	mov    0x10(%eax),%eax
801050cd:	eb 06                	jmp    801050d5 <getprocs+0xab>
801050cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d2:	8b 40 10             	mov    0x10(%eax),%eax
801050d5:	8b 55 0c             	mov    0xc(%ebp),%edx
801050d8:	89 42 0c             	mov    %eax,0xc(%edx)
    table->elapsed_ticks = ticks - begin->start_ticks;
801050db:	8b 15 c0 65 11 80    	mov    0x801165c0,%edx
801050e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050e4:	8b 40 7c             	mov    0x7c(%eax),%eax
801050e7:	29 c2                	sub    %eax,%edx
801050e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801050ec:	89 50 10             	mov    %edx,0x10(%eax)
    table->CPU_total_ticks = begin->cpu_ticks_total;
801050ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f2:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
801050f8:	8b 45 0c             	mov    0xc(%ebp),%eax
801050fb:	89 50 14             	mov    %edx,0x14(%eax)
    if(begin->state >= 0 && begin->state < NELEM(states) && states[begin->state])
801050fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105101:	8b 40 0c             	mov    0xc(%eax),%eax
80105104:	83 f8 05             	cmp    $0x5,%eax
80105107:	77 35                	ja     8010513e <getprocs+0x114>
80105109:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010510c:	8b 40 0c             	mov    0xc(%eax),%eax
8010510f:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105116:	85 c0                	test   %eax,%eax
80105118:	74 24                	je     8010513e <getprocs+0x114>
      safestrcpy(table->state, states[begin->state], sizeof(table->name));
8010511a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511d:	8b 40 0c             	mov    0xc(%eax),%eax
80105120:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80105127:	8b 55 0c             	mov    0xc(%ebp),%edx
8010512a:	83 c2 18             	add    $0x18,%edx
8010512d:	83 ec 04             	sub    $0x4,%esp
80105130:	6a 20                	push   $0x20
80105132:	50                   	push   %eax
80105133:	52                   	push   %edx
80105134:	e8 cb 06 00 00       	call   80105804 <safestrcpy>
80105139:	83 c4 10             	add    $0x10,%esp
8010513c:	eb 19                	jmp    80105157 <getprocs+0x12d>
    else
      safestrcpy(table->state, "???", sizeof(table->name));
8010513e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105141:	83 c0 18             	add    $0x18,%eax
80105144:	83 ec 04             	sub    $0x4,%esp
80105147:	6a 20                	push   $0x20
80105149:	68 2e 8e 10 80       	push   $0x80108e2e
8010514e:	50                   	push   %eax
8010514f:	e8 b0 06 00 00       	call   80105804 <safestrcpy>
80105154:	83 c4 10             	add    $0x10,%esp
      //table->state = "???";
    table->size = begin->sz;
80105157:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515a:	8b 10                	mov    (%eax),%edx
8010515c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010515f:	89 50 38             	mov    %edx,0x38(%eax)
    safestrcpy(table->name, begin->name, sizeof(table->name));
80105162:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105165:	8d 50 6c             	lea    0x6c(%eax),%edx
80105168:	8b 45 0c             	mov    0xc(%ebp),%eax
8010516b:	83 c0 3c             	add    $0x3c,%eax
8010516e:	83 ec 04             	sub    $0x4,%esp
80105171:	6a 20                	push   $0x20
80105173:	52                   	push   %edx
80105174:	50                   	push   %eax
80105175:	e8 8a 06 00 00       	call   80105804 <safestrcpy>
8010517a:	83 c4 10             	add    $0x10,%esp
    ++begin; ++table; ++num_uprocs;
8010517d:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80105184:	83 45 0c 5c          	addl   $0x5c,0xc(%ebp)
80105188:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  begin = ptable.proc;
  end = ptable.proc + NPROC;
  num_uprocs = 0;

  while (begin < end && num_uprocs < max) {
8010518c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010518f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105192:	73 0c                	jae    801051a0 <getprocs+0x176>
80105194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105197:	3b 45 08             	cmp    0x8(%ebp),%eax
8010519a:	0f 82 d0 fe ff ff    	jb     80105070 <getprocs+0x46>
      //table->state = "???";
    table->size = begin->sz;
    safestrcpy(table->name, begin->name, sizeof(table->name));
    ++begin; ++table; ++num_uprocs;
  }
  release(&ptable.lock);
801051a0:	83 ec 0c             	sub    $0xc,%esp
801051a3:	68 80 39 11 80       	push   $0x80113980
801051a8:	e8 58 02 00 00       	call   80105405 <release>
801051ad:	83 c4 10             	add    $0x10,%esp

  return num_uprocs;
801051b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801051b3:	c9                   	leave  
801051b4:	c3                   	ret    

801051b5 <procdump>:
#endif

void
procdump(void)
{
801051b5:	55                   	push   %ebp
801051b6:	89 e5                	mov    %esp,%ebp
801051b8:	53                   	push   %ebx
801051b9:	83 ec 44             	sub    $0x44,%esp
  char *state;
  uint pc[10];
  uint ppid;

  #ifdef CS333_P2
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
801051bc:	83 ec 0c             	sub    $0xc,%esp
801051bf:	68 34 8e 10 80       	push   $0x80108e34
801051c4:	e8 fd b1 ff ff       	call   801003c6 <cprintf>
801051c9:	83 c4 10             	add    $0x10,%esp
  #elif defined(CS333_P1)
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
  #endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051cc:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
801051d3:	e9 59 01 00 00       	jmp    80105331 <procdump+0x17c>
    if(p->state == UNUSED)
801051d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051db:	8b 40 0c             	mov    0xc(%eax),%eax
801051de:	85 c0                	test   %eax,%eax
801051e0:	0f 84 43 01 00 00    	je     80105329 <procdump+0x174>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801051e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051e9:	8b 40 0c             	mov    0xc(%eax),%eax
801051ec:	83 f8 05             	cmp    $0x5,%eax
801051ef:	77 23                	ja     80105214 <procdump+0x5f>
801051f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051f4:	8b 40 0c             	mov    0xc(%eax),%eax
801051f7:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
801051fe:	85 c0                	test   %eax,%eax
80105200:	74 12                	je     80105214 <procdump+0x5f>
      state = states[p->state];
80105202:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105205:	8b 40 0c             	mov    0xc(%eax),%eax
80105208:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
8010520f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105212:	eb 07                	jmp    8010521b <procdump+0x66>
    else
      state = "???";
80105214:	c7 45 ec 2e 8e 10 80 	movl   $0x80108e2e,-0x14(%ebp)
    #ifndef CS333_P1 
    cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
    #endif
    #ifdef CS333_P1
        #ifdef CS333_P2
          ppid = p->parent ? p->parent->pid : p->pid;
8010521b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010521e:	8b 40 14             	mov    0x14(%eax),%eax
80105221:	85 c0                	test   %eax,%eax
80105223:	74 0b                	je     80105230 <procdump+0x7b>
80105225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105228:	8b 40 14             	mov    0x14(%eax),%eax
8010522b:	8b 40 10             	mov    0x10(%eax),%eax
8010522e:	eb 06                	jmp    80105236 <procdump+0x81>
80105230:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105233:	8b 40 10             	mov    0x10(%eax),%eax
80105236:	89 45 e8             	mov    %eax,-0x18(%ebp)
          cprintf("%d\t%s\t%d\t%d\t%d\t", 
80105239:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010523c:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80105242:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105245:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
              p->pid, p->name, p->uid, p->gid, ppid);
8010524b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524e:	8d 58 6c             	lea    0x6c(%eax),%ebx
    cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
    #endif
    #ifdef CS333_P1
        #ifdef CS333_P2
          ppid = p->parent ? p->parent->pid : p->pid;
          cprintf("%d\t%s\t%d\t%d\t%d\t", 
80105251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105254:	8b 40 10             	mov    0x10(%eax),%eax
80105257:	83 ec 08             	sub    $0x8,%esp
8010525a:	ff 75 e8             	pushl  -0x18(%ebp)
8010525d:	51                   	push   %ecx
8010525e:	52                   	push   %edx
8010525f:	53                   	push   %ebx
80105260:	50                   	push   %eax
80105261:	68 68 8e 10 80       	push   $0x80108e68
80105266:	e8 5b b1 ff ff       	call   801003c6 <cprintf>
8010526b:	83 c4 20             	add    $0x20,%esp
              p->pid, p->name, p->uid, p->gid, ppid);
        #else
          cprintf("%d\t%s\t%s\t", p->pid, state, p->name);
        #endif
    // display elapsed time
      print_millisec(ticks - p->start_ticks);
8010526e:	8b 15 c0 65 11 80    	mov    0x801165c0,%edx
80105274:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105277:	8b 40 7c             	mov    0x7c(%eax),%eax
8010527a:	29 c2                	sub    %eax,%edx
8010527c:	89 d0                	mov    %edx,%eax
8010527e:	83 ec 0c             	sub    $0xc,%esp
80105281:	50                   	push   %eax
80105282:	e8 1d fd ff ff       	call   80104fa4 <print_millisec>
80105287:	83 c4 10             	add    $0x10,%esp
        #ifdef CS333_P2
          print_millisec(p->cpu_ticks_total);
8010528a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010528d:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80105293:	83 ec 0c             	sub    $0xc,%esp
80105296:	50                   	push   %eax
80105297:	e8 08 fd ff ff       	call   80104fa4 <print_millisec>
8010529c:	83 c4 10             	add    $0x10,%esp
          cprintf("%s\t%d\t",state,p->sz);
8010529f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a2:	8b 00                	mov    (%eax),%eax
801052a4:	83 ec 04             	sub    $0x4,%esp
801052a7:	50                   	push   %eax
801052a8:	ff 75 ec             	pushl  -0x14(%ebp)
801052ab:	68 78 8e 10 80       	push   $0x80108e78
801052b0:	e8 11 b1 ff ff       	call   801003c6 <cprintf>
801052b5:	83 c4 10             	add    $0x10,%esp
        #endif // CS333_P2
    #endif // CS333_p1

    if(p->state == SLEEPING){
801052b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052bb:	8b 40 0c             	mov    0xc(%eax),%eax
801052be:	83 f8 02             	cmp    $0x2,%eax
801052c1:	75 54                	jne    80105317 <procdump+0x162>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801052c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c6:	8b 40 1c             	mov    0x1c(%eax),%eax
801052c9:	8b 40 0c             	mov    0xc(%eax),%eax
801052cc:	83 c0 08             	add    $0x8,%eax
801052cf:	89 c2                	mov    %eax,%edx
801052d1:	83 ec 08             	sub    $0x8,%esp
801052d4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801052d7:	50                   	push   %eax
801052d8:	52                   	push   %edx
801052d9:	e8 79 01 00 00       	call   80105457 <getcallerpcs>
801052de:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801052e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052e8:	eb 1c                	jmp    80105306 <procdump+0x151>
        cprintf(" %p", pc[i]);
801052ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ed:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
801052f1:	83 ec 08             	sub    $0x8,%esp
801052f4:	50                   	push   %eax
801052f5:	68 7f 8e 10 80       	push   $0x80108e7f
801052fa:	e8 c7 b0 ff ff       	call   801003c6 <cprintf>
801052ff:	83 c4 10             	add    $0x10,%esp
        #endif // CS333_P2
    #endif // CS333_p1

    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105302:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105306:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010530a:	7f 0b                	jg     80105317 <procdump+0x162>
8010530c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010530f:	8b 44 85 c0          	mov    -0x40(%ebp,%eax,4),%eax
80105313:	85 c0                	test   %eax,%eax
80105315:	75 d3                	jne    801052ea <procdump+0x135>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105317:	83 ec 0c             	sub    $0xc,%esp
8010531a:	68 83 8e 10 80       	push   $0x80108e83
8010531f:	e8 a2 b0 ff ff       	call   801003c6 <cprintf>
80105324:	83 c4 10             	add    $0x10,%esp
80105327:	eb 01                	jmp    8010532a <procdump+0x175>
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
  #endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105329:	90                   	nop
  cprintf("\nPID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\t PCs\n");
  #elif defined(CS333_P1)
  cprintf("\nPID\tState\tName\tElapsed\t PCs\n");
  #endif

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010532a:	81 45 f0 90 00 00 00 	addl   $0x90,-0x10(%ebp)
80105331:	81 7d f0 b4 5d 11 80 	cmpl   $0x80115db4,-0x10(%ebp)
80105338:	0f 82 9a fe ff ff    	jb     801051d8 <procdump+0x23>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010533e:	90                   	nop
8010533f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105342:	c9                   	leave  
80105343:	c3                   	ret    

80105344 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105344:	55                   	push   %ebp
80105345:	89 e5                	mov    %esp,%ebp
80105347:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010534a:	9c                   	pushf  
8010534b:	58                   	pop    %eax
8010534c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010534f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105352:	c9                   	leave  
80105353:	c3                   	ret    

80105354 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105354:	55                   	push   %ebp
80105355:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105357:	fa                   	cli    
}
80105358:	90                   	nop
80105359:	5d                   	pop    %ebp
8010535a:	c3                   	ret    

8010535b <sti>:

static inline void
sti(void)
{
8010535b:	55                   	push   %ebp
8010535c:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010535e:	fb                   	sti    
}
8010535f:	90                   	nop
80105360:	5d                   	pop    %ebp
80105361:	c3                   	ret    

80105362 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105362:	55                   	push   %ebp
80105363:	89 e5                	mov    %esp,%ebp
80105365:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105368:	8b 55 08             	mov    0x8(%ebp),%edx
8010536b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010536e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105371:	f0 87 02             	lock xchg %eax,(%edx)
80105374:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105377:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010537a:	c9                   	leave  
8010537b:	c3                   	ret    

8010537c <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010537c:	55                   	push   %ebp
8010537d:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010537f:	8b 45 08             	mov    0x8(%ebp),%eax
80105382:	8b 55 0c             	mov    0xc(%ebp),%edx
80105385:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105388:	8b 45 08             	mov    0x8(%ebp),%eax
8010538b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105391:	8b 45 08             	mov    0x8(%ebp),%eax
80105394:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010539b:	90                   	nop
8010539c:	5d                   	pop    %ebp
8010539d:	c3                   	ret    

8010539e <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010539e:	55                   	push   %ebp
8010539f:	89 e5                	mov    %esp,%ebp
801053a1:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801053a4:	e8 52 01 00 00       	call   801054fb <pushcli>
  if(holding(lk))
801053a9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ac:	83 ec 0c             	sub    $0xc,%esp
801053af:	50                   	push   %eax
801053b0:	e8 1c 01 00 00       	call   801054d1 <holding>
801053b5:	83 c4 10             	add    $0x10,%esp
801053b8:	85 c0                	test   %eax,%eax
801053ba:	74 0d                	je     801053c9 <acquire+0x2b>
    panic("acquire");
801053bc:	83 ec 0c             	sub    $0xc,%esp
801053bf:	68 85 8e 10 80       	push   $0x80108e85
801053c4:	e8 9d b1 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801053c9:	90                   	nop
801053ca:	8b 45 08             	mov    0x8(%ebp),%eax
801053cd:	83 ec 08             	sub    $0x8,%esp
801053d0:	6a 01                	push   $0x1
801053d2:	50                   	push   %eax
801053d3:	e8 8a ff ff ff       	call   80105362 <xchg>
801053d8:	83 c4 10             	add    $0x10,%esp
801053db:	85 c0                	test   %eax,%eax
801053dd:	75 eb                	jne    801053ca <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801053df:	8b 45 08             	mov    0x8(%ebp),%eax
801053e2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801053e9:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801053ec:	8b 45 08             	mov    0x8(%ebp),%eax
801053ef:	83 c0 0c             	add    $0xc,%eax
801053f2:	83 ec 08             	sub    $0x8,%esp
801053f5:	50                   	push   %eax
801053f6:	8d 45 08             	lea    0x8(%ebp),%eax
801053f9:	50                   	push   %eax
801053fa:	e8 58 00 00 00       	call   80105457 <getcallerpcs>
801053ff:	83 c4 10             	add    $0x10,%esp
}
80105402:	90                   	nop
80105403:	c9                   	leave  
80105404:	c3                   	ret    

80105405 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105405:	55                   	push   %ebp
80105406:	89 e5                	mov    %esp,%ebp
80105408:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010540b:	83 ec 0c             	sub    $0xc,%esp
8010540e:	ff 75 08             	pushl  0x8(%ebp)
80105411:	e8 bb 00 00 00       	call   801054d1 <holding>
80105416:	83 c4 10             	add    $0x10,%esp
80105419:	85 c0                	test   %eax,%eax
8010541b:	75 0d                	jne    8010542a <release+0x25>
    panic("release");
8010541d:	83 ec 0c             	sub    $0xc,%esp
80105420:	68 8d 8e 10 80       	push   $0x80108e8d
80105425:	e8 3c b1 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
8010542a:	8b 45 08             	mov    0x8(%ebp),%eax
8010542d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105434:	8b 45 08             	mov    0x8(%ebp),%eax
80105437:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
8010543e:	8b 45 08             	mov    0x8(%ebp),%eax
80105441:	83 ec 08             	sub    $0x8,%esp
80105444:	6a 00                	push   $0x0
80105446:	50                   	push   %eax
80105447:	e8 16 ff ff ff       	call   80105362 <xchg>
8010544c:	83 c4 10             	add    $0x10,%esp

  popcli();
8010544f:	e8 ec 00 00 00       	call   80105540 <popcli>
}
80105454:	90                   	nop
80105455:	c9                   	leave  
80105456:	c3                   	ret    

80105457 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105457:	55                   	push   %ebp
80105458:	89 e5                	mov    %esp,%ebp
8010545a:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
8010545d:	8b 45 08             	mov    0x8(%ebp),%eax
80105460:	83 e8 08             	sub    $0x8,%eax
80105463:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105466:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010546d:	eb 38                	jmp    801054a7 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010546f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105473:	74 53                	je     801054c8 <getcallerpcs+0x71>
80105475:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010547c:	76 4a                	jbe    801054c8 <getcallerpcs+0x71>
8010547e:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105482:	74 44                	je     801054c8 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105484:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105487:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010548e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105491:	01 c2                	add    %eax,%edx
80105493:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105496:	8b 40 04             	mov    0x4(%eax),%eax
80105499:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010549b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010549e:	8b 00                	mov    (%eax),%eax
801054a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801054a3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054a7:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054ab:	7e c2                	jle    8010546f <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054ad:	eb 19                	jmp    801054c8 <getcallerpcs+0x71>
    pcs[i] = 0;
801054af:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801054b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801054bc:	01 d0                	add    %edx,%eax
801054be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801054c4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801054c8:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801054cc:	7e e1                	jle    801054af <getcallerpcs+0x58>
    pcs[i] = 0;
}
801054ce:	90                   	nop
801054cf:	c9                   	leave  
801054d0:	c3                   	ret    

801054d1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801054d1:	55                   	push   %ebp
801054d2:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801054d4:	8b 45 08             	mov    0x8(%ebp),%eax
801054d7:	8b 00                	mov    (%eax),%eax
801054d9:	85 c0                	test   %eax,%eax
801054db:	74 17                	je     801054f4 <holding+0x23>
801054dd:	8b 45 08             	mov    0x8(%ebp),%eax
801054e0:	8b 50 08             	mov    0x8(%eax),%edx
801054e3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801054e9:	39 c2                	cmp    %eax,%edx
801054eb:	75 07                	jne    801054f4 <holding+0x23>
801054ed:	b8 01 00 00 00       	mov    $0x1,%eax
801054f2:	eb 05                	jmp    801054f9 <holding+0x28>
801054f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054f9:	5d                   	pop    %ebp
801054fa:	c3                   	ret    

801054fb <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801054fb:	55                   	push   %ebp
801054fc:	89 e5                	mov    %esp,%ebp
801054fe:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105501:	e8 3e fe ff ff       	call   80105344 <readeflags>
80105506:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105509:	e8 46 fe ff ff       	call   80105354 <cli>
  if(cpu->ncli++ == 0)
8010550e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105515:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
8010551b:	8d 48 01             	lea    0x1(%eax),%ecx
8010551e:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105524:	85 c0                	test   %eax,%eax
80105526:	75 15                	jne    8010553d <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105528:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010552e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105531:	81 e2 00 02 00 00    	and    $0x200,%edx
80105537:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
8010553d:	90                   	nop
8010553e:	c9                   	leave  
8010553f:	c3                   	ret    

80105540 <popcli>:

void
popcli(void)
{
80105540:	55                   	push   %ebp
80105541:	89 e5                	mov    %esp,%ebp
80105543:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105546:	e8 f9 fd ff ff       	call   80105344 <readeflags>
8010554b:	25 00 02 00 00       	and    $0x200,%eax
80105550:	85 c0                	test   %eax,%eax
80105552:	74 0d                	je     80105561 <popcli+0x21>
    panic("popcli - interruptible");
80105554:	83 ec 0c             	sub    $0xc,%esp
80105557:	68 95 8e 10 80       	push   $0x80108e95
8010555c:	e8 05 b0 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
80105561:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105567:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010556d:	83 ea 01             	sub    $0x1,%edx
80105570:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105576:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010557c:	85 c0                	test   %eax,%eax
8010557e:	79 0d                	jns    8010558d <popcli+0x4d>
    panic("popcli");
80105580:	83 ec 0c             	sub    $0xc,%esp
80105583:	68 ac 8e 10 80       	push   $0x80108eac
80105588:	e8 d9 af ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010558d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105593:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105599:	85 c0                	test   %eax,%eax
8010559b:	75 15                	jne    801055b2 <popcli+0x72>
8010559d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801055a3:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801055a9:	85 c0                	test   %eax,%eax
801055ab:	74 05                	je     801055b2 <popcli+0x72>
    sti();
801055ad:	e8 a9 fd ff ff       	call   8010535b <sti>
}
801055b2:	90                   	nop
801055b3:	c9                   	leave  
801055b4:	c3                   	ret    

801055b5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801055b5:	55                   	push   %ebp
801055b6:	89 e5                	mov    %esp,%ebp
801055b8:	57                   	push   %edi
801055b9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801055ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055bd:	8b 55 10             	mov    0x10(%ebp),%edx
801055c0:	8b 45 0c             	mov    0xc(%ebp),%eax
801055c3:	89 cb                	mov    %ecx,%ebx
801055c5:	89 df                	mov    %ebx,%edi
801055c7:	89 d1                	mov    %edx,%ecx
801055c9:	fc                   	cld    
801055ca:	f3 aa                	rep stos %al,%es:(%edi)
801055cc:	89 ca                	mov    %ecx,%edx
801055ce:	89 fb                	mov    %edi,%ebx
801055d0:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055d3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055d6:	90                   	nop
801055d7:	5b                   	pop    %ebx
801055d8:	5f                   	pop    %edi
801055d9:	5d                   	pop    %ebp
801055da:	c3                   	ret    

801055db <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801055db:	55                   	push   %ebp
801055dc:	89 e5                	mov    %esp,%ebp
801055de:	57                   	push   %edi
801055df:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801055e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
801055e3:	8b 55 10             	mov    0x10(%ebp),%edx
801055e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e9:	89 cb                	mov    %ecx,%ebx
801055eb:	89 df                	mov    %ebx,%edi
801055ed:	89 d1                	mov    %edx,%ecx
801055ef:	fc                   	cld    
801055f0:	f3 ab                	rep stos %eax,%es:(%edi)
801055f2:	89 ca                	mov    %ecx,%edx
801055f4:	89 fb                	mov    %edi,%ebx
801055f6:	89 5d 08             	mov    %ebx,0x8(%ebp)
801055f9:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801055fc:	90                   	nop
801055fd:	5b                   	pop    %ebx
801055fe:	5f                   	pop    %edi
801055ff:	5d                   	pop    %ebp
80105600:	c3                   	ret    

80105601 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105601:	55                   	push   %ebp
80105602:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80105604:	8b 45 08             	mov    0x8(%ebp),%eax
80105607:	83 e0 03             	and    $0x3,%eax
8010560a:	85 c0                	test   %eax,%eax
8010560c:	75 43                	jne    80105651 <memset+0x50>
8010560e:	8b 45 10             	mov    0x10(%ebp),%eax
80105611:	83 e0 03             	and    $0x3,%eax
80105614:	85 c0                	test   %eax,%eax
80105616:	75 39                	jne    80105651 <memset+0x50>
    c &= 0xFF;
80105618:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010561f:	8b 45 10             	mov    0x10(%ebp),%eax
80105622:	c1 e8 02             	shr    $0x2,%eax
80105625:	89 c1                	mov    %eax,%ecx
80105627:	8b 45 0c             	mov    0xc(%ebp),%eax
8010562a:	c1 e0 18             	shl    $0x18,%eax
8010562d:	89 c2                	mov    %eax,%edx
8010562f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105632:	c1 e0 10             	shl    $0x10,%eax
80105635:	09 c2                	or     %eax,%edx
80105637:	8b 45 0c             	mov    0xc(%ebp),%eax
8010563a:	c1 e0 08             	shl    $0x8,%eax
8010563d:	09 d0                	or     %edx,%eax
8010563f:	0b 45 0c             	or     0xc(%ebp),%eax
80105642:	51                   	push   %ecx
80105643:	50                   	push   %eax
80105644:	ff 75 08             	pushl  0x8(%ebp)
80105647:	e8 8f ff ff ff       	call   801055db <stosl>
8010564c:	83 c4 0c             	add    $0xc,%esp
8010564f:	eb 12                	jmp    80105663 <memset+0x62>
  } else
    stosb(dst, c, n);
80105651:	8b 45 10             	mov    0x10(%ebp),%eax
80105654:	50                   	push   %eax
80105655:	ff 75 0c             	pushl  0xc(%ebp)
80105658:	ff 75 08             	pushl  0x8(%ebp)
8010565b:	e8 55 ff ff ff       	call   801055b5 <stosb>
80105660:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105663:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105666:	c9                   	leave  
80105667:	c3                   	ret    

80105668 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105668:	55                   	push   %ebp
80105669:	89 e5                	mov    %esp,%ebp
8010566b:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
8010566e:	8b 45 08             	mov    0x8(%ebp),%eax
80105671:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105674:	8b 45 0c             	mov    0xc(%ebp),%eax
80105677:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010567a:	eb 30                	jmp    801056ac <memcmp+0x44>
    if(*s1 != *s2)
8010567c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010567f:	0f b6 10             	movzbl (%eax),%edx
80105682:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105685:	0f b6 00             	movzbl (%eax),%eax
80105688:	38 c2                	cmp    %al,%dl
8010568a:	74 18                	je     801056a4 <memcmp+0x3c>
      return *s1 - *s2;
8010568c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010568f:	0f b6 00             	movzbl (%eax),%eax
80105692:	0f b6 d0             	movzbl %al,%edx
80105695:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105698:	0f b6 00             	movzbl (%eax),%eax
8010569b:	0f b6 c0             	movzbl %al,%eax
8010569e:	29 c2                	sub    %eax,%edx
801056a0:	89 d0                	mov    %edx,%eax
801056a2:	eb 1a                	jmp    801056be <memcmp+0x56>
    s1++, s2++;
801056a4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801056a8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801056ac:	8b 45 10             	mov    0x10(%ebp),%eax
801056af:	8d 50 ff             	lea    -0x1(%eax),%edx
801056b2:	89 55 10             	mov    %edx,0x10(%ebp)
801056b5:	85 c0                	test   %eax,%eax
801056b7:	75 c3                	jne    8010567c <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801056b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056be:	c9                   	leave  
801056bf:	c3                   	ret    

801056c0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801056c0:	55                   	push   %ebp
801056c1:	89 e5                	mov    %esp,%ebp
801056c3:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801056c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801056cc:	8b 45 08             	mov    0x8(%ebp),%eax
801056cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801056d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056d5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056d8:	73 54                	jae    8010572e <memmove+0x6e>
801056da:	8b 55 fc             	mov    -0x4(%ebp),%edx
801056dd:	8b 45 10             	mov    0x10(%ebp),%eax
801056e0:	01 d0                	add    %edx,%eax
801056e2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801056e5:	76 47                	jbe    8010572e <memmove+0x6e>
    s += n;
801056e7:	8b 45 10             	mov    0x10(%ebp),%eax
801056ea:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801056ed:	8b 45 10             	mov    0x10(%ebp),%eax
801056f0:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801056f3:	eb 13                	jmp    80105708 <memmove+0x48>
      *--d = *--s;
801056f5:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801056f9:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801056fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105700:	0f b6 10             	movzbl (%eax),%edx
80105703:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105706:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105708:	8b 45 10             	mov    0x10(%ebp),%eax
8010570b:	8d 50 ff             	lea    -0x1(%eax),%edx
8010570e:	89 55 10             	mov    %edx,0x10(%ebp)
80105711:	85 c0                	test   %eax,%eax
80105713:	75 e0                	jne    801056f5 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105715:	eb 24                	jmp    8010573b <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105717:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010571a:	8d 50 01             	lea    0x1(%eax),%edx
8010571d:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105720:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105723:	8d 4a 01             	lea    0x1(%edx),%ecx
80105726:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105729:	0f b6 12             	movzbl (%edx),%edx
8010572c:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010572e:	8b 45 10             	mov    0x10(%ebp),%eax
80105731:	8d 50 ff             	lea    -0x1(%eax),%edx
80105734:	89 55 10             	mov    %edx,0x10(%ebp)
80105737:	85 c0                	test   %eax,%eax
80105739:	75 dc                	jne    80105717 <memmove+0x57>
      *d++ = *s++;

  return dst;
8010573b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010573e:	c9                   	leave  
8010573f:	c3                   	ret    

80105740 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105740:	55                   	push   %ebp
80105741:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105743:	ff 75 10             	pushl  0x10(%ebp)
80105746:	ff 75 0c             	pushl  0xc(%ebp)
80105749:	ff 75 08             	pushl  0x8(%ebp)
8010574c:	e8 6f ff ff ff       	call   801056c0 <memmove>
80105751:	83 c4 0c             	add    $0xc,%esp
}
80105754:	c9                   	leave  
80105755:	c3                   	ret    

80105756 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105756:	55                   	push   %ebp
80105757:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105759:	eb 0c                	jmp    80105767 <strncmp+0x11>
    n--, p++, q++;
8010575b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010575f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105763:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105767:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010576b:	74 1a                	je     80105787 <strncmp+0x31>
8010576d:	8b 45 08             	mov    0x8(%ebp),%eax
80105770:	0f b6 00             	movzbl (%eax),%eax
80105773:	84 c0                	test   %al,%al
80105775:	74 10                	je     80105787 <strncmp+0x31>
80105777:	8b 45 08             	mov    0x8(%ebp),%eax
8010577a:	0f b6 10             	movzbl (%eax),%edx
8010577d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105780:	0f b6 00             	movzbl (%eax),%eax
80105783:	38 c2                	cmp    %al,%dl
80105785:	74 d4                	je     8010575b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105787:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010578b:	75 07                	jne    80105794 <strncmp+0x3e>
    return 0;
8010578d:	b8 00 00 00 00       	mov    $0x0,%eax
80105792:	eb 16                	jmp    801057aa <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105794:	8b 45 08             	mov    0x8(%ebp),%eax
80105797:	0f b6 00             	movzbl (%eax),%eax
8010579a:	0f b6 d0             	movzbl %al,%edx
8010579d:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a0:	0f b6 00             	movzbl (%eax),%eax
801057a3:	0f b6 c0             	movzbl %al,%eax
801057a6:	29 c2                	sub    %eax,%edx
801057a8:	89 d0                	mov    %edx,%eax
}
801057aa:	5d                   	pop    %ebp
801057ab:	c3                   	ret    

801057ac <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801057ac:	55                   	push   %ebp
801057ad:	89 e5                	mov    %esp,%ebp
801057af:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801057b2:	8b 45 08             	mov    0x8(%ebp),%eax
801057b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801057b8:	90                   	nop
801057b9:	8b 45 10             	mov    0x10(%ebp),%eax
801057bc:	8d 50 ff             	lea    -0x1(%eax),%edx
801057bf:	89 55 10             	mov    %edx,0x10(%ebp)
801057c2:	85 c0                	test   %eax,%eax
801057c4:	7e 2c                	jle    801057f2 <strncpy+0x46>
801057c6:	8b 45 08             	mov    0x8(%ebp),%eax
801057c9:	8d 50 01             	lea    0x1(%eax),%edx
801057cc:	89 55 08             	mov    %edx,0x8(%ebp)
801057cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801057d2:	8d 4a 01             	lea    0x1(%edx),%ecx
801057d5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801057d8:	0f b6 12             	movzbl (%edx),%edx
801057db:	88 10                	mov    %dl,(%eax)
801057dd:	0f b6 00             	movzbl (%eax),%eax
801057e0:	84 c0                	test   %al,%al
801057e2:	75 d5                	jne    801057b9 <strncpy+0xd>
    ;
  while(n-- > 0)
801057e4:	eb 0c                	jmp    801057f2 <strncpy+0x46>
    *s++ = 0;
801057e6:	8b 45 08             	mov    0x8(%ebp),%eax
801057e9:	8d 50 01             	lea    0x1(%eax),%edx
801057ec:	89 55 08             	mov    %edx,0x8(%ebp)
801057ef:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801057f2:	8b 45 10             	mov    0x10(%ebp),%eax
801057f5:	8d 50 ff             	lea    -0x1(%eax),%edx
801057f8:	89 55 10             	mov    %edx,0x10(%ebp)
801057fb:	85 c0                	test   %eax,%eax
801057fd:	7f e7                	jg     801057e6 <strncpy+0x3a>
    *s++ = 0;
  return os;
801057ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105802:	c9                   	leave  
80105803:	c3                   	ret    

80105804 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105804:	55                   	push   %ebp
80105805:	89 e5                	mov    %esp,%ebp
80105807:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010580a:	8b 45 08             	mov    0x8(%ebp),%eax
8010580d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105810:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105814:	7f 05                	jg     8010581b <safestrcpy+0x17>
    return os;
80105816:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105819:	eb 31                	jmp    8010584c <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
8010581b:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010581f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105823:	7e 1e                	jle    80105843 <safestrcpy+0x3f>
80105825:	8b 45 08             	mov    0x8(%ebp),%eax
80105828:	8d 50 01             	lea    0x1(%eax),%edx
8010582b:	89 55 08             	mov    %edx,0x8(%ebp)
8010582e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105831:	8d 4a 01             	lea    0x1(%edx),%ecx
80105834:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105837:	0f b6 12             	movzbl (%edx),%edx
8010583a:	88 10                	mov    %dl,(%eax)
8010583c:	0f b6 00             	movzbl (%eax),%eax
8010583f:	84 c0                	test   %al,%al
80105841:	75 d8                	jne    8010581b <safestrcpy+0x17>
    ;
  *s = 0;
80105843:	8b 45 08             	mov    0x8(%ebp),%eax
80105846:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105849:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010584c:	c9                   	leave  
8010584d:	c3                   	ret    

8010584e <strlen>:

int
strlen(const char *s)
{
8010584e:	55                   	push   %ebp
8010584f:	89 e5                	mov    %esp,%ebp
80105851:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105854:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010585b:	eb 04                	jmp    80105861 <strlen+0x13>
8010585d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105861:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105864:	8b 45 08             	mov    0x8(%ebp),%eax
80105867:	01 d0                	add    %edx,%eax
80105869:	0f b6 00             	movzbl (%eax),%eax
8010586c:	84 c0                	test   %al,%al
8010586e:	75 ed                	jne    8010585d <strlen+0xf>
    ;
  return n;
80105870:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105873:	c9                   	leave  
80105874:	c3                   	ret    

80105875 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105875:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105879:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010587d:	55                   	push   %ebp
  pushl %ebx
8010587e:	53                   	push   %ebx
  pushl %esi
8010587f:	56                   	push   %esi
  pushl %edi
80105880:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105881:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105883:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105885:	5f                   	pop    %edi
  popl %esi
80105886:	5e                   	pop    %esi
  popl %ebx
80105887:	5b                   	pop    %ebx
  popl %ebp
80105888:	5d                   	pop    %ebp
  ret
80105889:	c3                   	ret    

8010588a <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
8010588a:	55                   	push   %ebp
8010588b:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
8010588d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105893:	8b 00                	mov    (%eax),%eax
80105895:	3b 45 08             	cmp    0x8(%ebp),%eax
80105898:	76 12                	jbe    801058ac <fetchint+0x22>
8010589a:	8b 45 08             	mov    0x8(%ebp),%eax
8010589d:	8d 50 04             	lea    0x4(%eax),%edx
801058a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a6:	8b 00                	mov    (%eax),%eax
801058a8:	39 c2                	cmp    %eax,%edx
801058aa:	76 07                	jbe    801058b3 <fetchint+0x29>
    return -1;
801058ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b1:	eb 0f                	jmp    801058c2 <fetchint+0x38>
  *ip = *(int*)(addr);
801058b3:	8b 45 08             	mov    0x8(%ebp),%eax
801058b6:	8b 10                	mov    (%eax),%edx
801058b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801058bb:	89 10                	mov    %edx,(%eax)
  return 0;
801058bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058c2:	5d                   	pop    %ebp
801058c3:	c3                   	ret    

801058c4 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801058c4:	55                   	push   %ebp
801058c5:	89 e5                	mov    %esp,%ebp
801058c7:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801058ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058d0:	8b 00                	mov    (%eax),%eax
801058d2:	3b 45 08             	cmp    0x8(%ebp),%eax
801058d5:	77 07                	ja     801058de <fetchstr+0x1a>
    return -1;
801058d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058dc:	eb 46                	jmp    80105924 <fetchstr+0x60>
  *pp = (char*)addr;
801058de:	8b 55 08             	mov    0x8(%ebp),%edx
801058e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801058e4:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801058e6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058ec:	8b 00                	mov    (%eax),%eax
801058ee:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801058f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801058f4:	8b 00                	mov    (%eax),%eax
801058f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
801058f9:	eb 1c                	jmp    80105917 <fetchstr+0x53>
    if(*s == 0)
801058fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058fe:	0f b6 00             	movzbl (%eax),%eax
80105901:	84 c0                	test   %al,%al
80105903:	75 0e                	jne    80105913 <fetchstr+0x4f>
      return s - *pp;
80105905:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105908:	8b 45 0c             	mov    0xc(%ebp),%eax
8010590b:	8b 00                	mov    (%eax),%eax
8010590d:	29 c2                	sub    %eax,%edx
8010590f:	89 d0                	mov    %edx,%eax
80105911:	eb 11                	jmp    80105924 <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105913:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105917:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010591a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
8010591d:	72 dc                	jb     801058fb <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
8010591f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105924:	c9                   	leave  
80105925:	c3                   	ret    

80105926 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105926:	55                   	push   %ebp
80105927:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105929:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010592f:	8b 40 18             	mov    0x18(%eax),%eax
80105932:	8b 40 44             	mov    0x44(%eax),%eax
80105935:	8b 55 08             	mov    0x8(%ebp),%edx
80105938:	c1 e2 02             	shl    $0x2,%edx
8010593b:	01 d0                	add    %edx,%eax
8010593d:	83 c0 04             	add    $0x4,%eax
80105940:	ff 75 0c             	pushl  0xc(%ebp)
80105943:	50                   	push   %eax
80105944:	e8 41 ff ff ff       	call   8010588a <fetchint>
80105949:	83 c4 08             	add    $0x8,%esp
}
8010594c:	c9                   	leave  
8010594d:	c3                   	ret    

8010594e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010594e:	55                   	push   %ebp
8010594f:	89 e5                	mov    %esp,%ebp
80105951:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80105954:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105957:	50                   	push   %eax
80105958:	ff 75 08             	pushl  0x8(%ebp)
8010595b:	e8 c6 ff ff ff       	call   80105926 <argint>
80105960:	83 c4 08             	add    $0x8,%esp
80105963:	85 c0                	test   %eax,%eax
80105965:	79 07                	jns    8010596e <argptr+0x20>
    return -1;
80105967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596c:	eb 3b                	jmp    801059a9 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010596e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105974:	8b 00                	mov    (%eax),%eax
80105976:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105979:	39 d0                	cmp    %edx,%eax
8010597b:	76 16                	jbe    80105993 <argptr+0x45>
8010597d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105980:	89 c2                	mov    %eax,%edx
80105982:	8b 45 10             	mov    0x10(%ebp),%eax
80105985:	01 c2                	add    %eax,%edx
80105987:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010598d:	8b 00                	mov    (%eax),%eax
8010598f:	39 c2                	cmp    %eax,%edx
80105991:	76 07                	jbe    8010599a <argptr+0x4c>
    return -1;
80105993:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105998:	eb 0f                	jmp    801059a9 <argptr+0x5b>
  *pp = (char*)i;
8010599a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010599d:	89 c2                	mov    %eax,%edx
8010599f:	8b 45 0c             	mov    0xc(%ebp),%eax
801059a2:	89 10                	mov    %edx,(%eax)
  return 0;
801059a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a9:	c9                   	leave  
801059aa:	c3                   	ret    

801059ab <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801059ab:	55                   	push   %ebp
801059ac:	89 e5                	mov    %esp,%ebp
801059ae:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801059b1:	8d 45 fc             	lea    -0x4(%ebp),%eax
801059b4:	50                   	push   %eax
801059b5:	ff 75 08             	pushl  0x8(%ebp)
801059b8:	e8 69 ff ff ff       	call   80105926 <argint>
801059bd:	83 c4 08             	add    $0x8,%esp
801059c0:	85 c0                	test   %eax,%eax
801059c2:	79 07                	jns    801059cb <argstr+0x20>
    return -1;
801059c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c9:	eb 0f                	jmp    801059da <argstr+0x2f>
  return fetchstr(addr, pp);
801059cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059ce:	ff 75 0c             	pushl  0xc(%ebp)
801059d1:	50                   	push   %eax
801059d2:	e8 ed fe ff ff       	call   801058c4 <fetchstr>
801059d7:	83 c4 08             	add    $0x8,%esp
}
801059da:	c9                   	leave  
801059db:	c3                   	ret    

801059dc <syscall>:
};
#endif

void
syscall(void)
{
801059dc:	55                   	push   %ebp
801059dd:	89 e5                	mov    %esp,%ebp
801059df:	53                   	push   %ebx
801059e0:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801059e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801059e9:	8b 40 18             	mov    0x18(%eax),%eax
801059ec:	8b 40 1c             	mov    0x1c(%eax),%eax
801059ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801059f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059f6:	7e 30                	jle    80105a28 <syscall+0x4c>
801059f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fb:	83 f8 1d             	cmp    $0x1d,%eax
801059fe:	77 28                	ja     80105a28 <syscall+0x4c>
80105a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a03:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a0a:	85 c0                	test   %eax,%eax
80105a0c:	74 1a                	je     80105a28 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105a0e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a14:	8b 58 18             	mov    0x18(%eax),%ebx
80105a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a1a:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105a21:	ff d0                	call   *%eax
80105a23:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105a26:	eb 34                	jmp    80105a5c <syscall+0x80>
    #ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
    #endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105a28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a2e:	8d 50 6c             	lea    0x6c(%eax),%edx
80105a31:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
// some code goes here
    #ifdef PRINT_SYSCALLS
    cprintf("%s -> %d\n", syscallnames[num], proc->tf->eax);
    #endif
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105a37:	8b 40 10             	mov    0x10(%eax),%eax
80105a3a:	ff 75 f4             	pushl  -0xc(%ebp)
80105a3d:	52                   	push   %edx
80105a3e:	50                   	push   %eax
80105a3f:	68 b3 8e 10 80       	push   $0x80108eb3
80105a44:	e8 7d a9 ff ff       	call   801003c6 <cprintf>
80105a49:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105a4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a52:	8b 40 18             	mov    0x18(%eax),%eax
80105a55:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105a5c:	90                   	nop
80105a5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105a60:	c9                   	leave  
80105a61:	c3                   	ret    

80105a62 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105a62:	55                   	push   %ebp
80105a63:	89 e5                	mov    %esp,%ebp
80105a65:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105a68:	83 ec 08             	sub    $0x8,%esp
80105a6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a6e:	50                   	push   %eax
80105a6f:	ff 75 08             	pushl  0x8(%ebp)
80105a72:	e8 af fe ff ff       	call   80105926 <argint>
80105a77:	83 c4 10             	add    $0x10,%esp
80105a7a:	85 c0                	test   %eax,%eax
80105a7c:	79 07                	jns    80105a85 <argfd+0x23>
    return -1;
80105a7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a83:	eb 50                	jmp    80105ad5 <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a88:	85 c0                	test   %eax,%eax
80105a8a:	78 21                	js     80105aad <argfd+0x4b>
80105a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a8f:	83 f8 0f             	cmp    $0xf,%eax
80105a92:	7f 19                	jg     80105aad <argfd+0x4b>
80105a94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a9a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a9d:	83 c2 08             	add    $0x8,%edx
80105aa0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105aa4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105aa7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105aab:	75 07                	jne    80105ab4 <argfd+0x52>
    return -1;
80105aad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab2:	eb 21                	jmp    80105ad5 <argfd+0x73>
  if(pfd)
80105ab4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ab8:	74 08                	je     80105ac2 <argfd+0x60>
    *pfd = fd;
80105aba:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105abd:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ac0:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ac2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ac6:	74 08                	je     80105ad0 <argfd+0x6e>
    *pf = f;
80105ac8:	8b 45 10             	mov    0x10(%ebp),%eax
80105acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ace:	89 10                	mov    %edx,(%eax)
  return 0;
80105ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ad5:	c9                   	leave  
80105ad6:	c3                   	ret    

80105ad7 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ad7:	55                   	push   %ebp
80105ad8:	89 e5                	mov    %esp,%ebp
80105ada:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105add:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105ae4:	eb 30                	jmp    80105b16 <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105ae6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105aec:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105aef:	83 c2 08             	add    $0x8,%edx
80105af2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105af6:	85 c0                	test   %eax,%eax
80105af8:	75 18                	jne    80105b12 <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105afa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105b00:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b03:	8d 4a 08             	lea    0x8(%edx),%ecx
80105b06:	8b 55 08             	mov    0x8(%ebp),%edx
80105b09:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105b0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105b10:	eb 0f                	jmp    80105b21 <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105b12:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105b16:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105b1a:	7e ca                	jle    80105ae6 <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b21:	c9                   	leave  
80105b22:	c3                   	ret    

80105b23 <sys_dup>:

int
sys_dup(void)
{
80105b23:	55                   	push   %ebp
80105b24:	89 e5                	mov    %esp,%ebp
80105b26:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105b29:	83 ec 04             	sub    $0x4,%esp
80105b2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b2f:	50                   	push   %eax
80105b30:	6a 00                	push   $0x0
80105b32:	6a 00                	push   $0x0
80105b34:	e8 29 ff ff ff       	call   80105a62 <argfd>
80105b39:	83 c4 10             	add    $0x10,%esp
80105b3c:	85 c0                	test   %eax,%eax
80105b3e:	79 07                	jns    80105b47 <sys_dup+0x24>
    return -1;
80105b40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b45:	eb 31                	jmp    80105b78 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105b47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b4a:	83 ec 0c             	sub    $0xc,%esp
80105b4d:	50                   	push   %eax
80105b4e:	e8 84 ff ff ff       	call   80105ad7 <fdalloc>
80105b53:	83 c4 10             	add    $0x10,%esp
80105b56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b5d:	79 07                	jns    80105b66 <sys_dup+0x43>
    return -1;
80105b5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b64:	eb 12                	jmp    80105b78 <sys_dup+0x55>
  filedup(f);
80105b66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b69:	83 ec 0c             	sub    $0xc,%esp
80105b6c:	50                   	push   %eax
80105b6d:	e8 8e b4 ff ff       	call   80101000 <filedup>
80105b72:	83 c4 10             	add    $0x10,%esp
  return fd;
80105b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105b78:	c9                   	leave  
80105b79:	c3                   	ret    

80105b7a <sys_read>:

int
sys_read(void)
{
80105b7a:	55                   	push   %ebp
80105b7b:	89 e5                	mov    %esp,%ebp
80105b7d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105b80:	83 ec 04             	sub    $0x4,%esp
80105b83:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105b86:	50                   	push   %eax
80105b87:	6a 00                	push   $0x0
80105b89:	6a 00                	push   $0x0
80105b8b:	e8 d2 fe ff ff       	call   80105a62 <argfd>
80105b90:	83 c4 10             	add    $0x10,%esp
80105b93:	85 c0                	test   %eax,%eax
80105b95:	78 2e                	js     80105bc5 <sys_read+0x4b>
80105b97:	83 ec 08             	sub    $0x8,%esp
80105b9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b9d:	50                   	push   %eax
80105b9e:	6a 02                	push   $0x2
80105ba0:	e8 81 fd ff ff       	call   80105926 <argint>
80105ba5:	83 c4 10             	add    $0x10,%esp
80105ba8:	85 c0                	test   %eax,%eax
80105baa:	78 19                	js     80105bc5 <sys_read+0x4b>
80105bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105baf:	83 ec 04             	sub    $0x4,%esp
80105bb2:	50                   	push   %eax
80105bb3:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105bb6:	50                   	push   %eax
80105bb7:	6a 01                	push   $0x1
80105bb9:	e8 90 fd ff ff       	call   8010594e <argptr>
80105bbe:	83 c4 10             	add    $0x10,%esp
80105bc1:	85 c0                	test   %eax,%eax
80105bc3:	79 07                	jns    80105bcc <sys_read+0x52>
    return -1;
80105bc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bca:	eb 17                	jmp    80105be3 <sys_read+0x69>
  return fileread(f, p, n);
80105bcc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105bcf:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd5:	83 ec 04             	sub    $0x4,%esp
80105bd8:	51                   	push   %ecx
80105bd9:	52                   	push   %edx
80105bda:	50                   	push   %eax
80105bdb:	e8 b0 b5 ff ff       	call   80101190 <fileread>
80105be0:	83 c4 10             	add    $0x10,%esp
}
80105be3:	c9                   	leave  
80105be4:	c3                   	ret    

80105be5 <sys_write>:

int
sys_write(void)
{
80105be5:	55                   	push   %ebp
80105be6:	89 e5                	mov    %esp,%ebp
80105be8:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105beb:	83 ec 04             	sub    $0x4,%esp
80105bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bf1:	50                   	push   %eax
80105bf2:	6a 00                	push   $0x0
80105bf4:	6a 00                	push   $0x0
80105bf6:	e8 67 fe ff ff       	call   80105a62 <argfd>
80105bfb:	83 c4 10             	add    $0x10,%esp
80105bfe:	85 c0                	test   %eax,%eax
80105c00:	78 2e                	js     80105c30 <sys_write+0x4b>
80105c02:	83 ec 08             	sub    $0x8,%esp
80105c05:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c08:	50                   	push   %eax
80105c09:	6a 02                	push   $0x2
80105c0b:	e8 16 fd ff ff       	call   80105926 <argint>
80105c10:	83 c4 10             	add    $0x10,%esp
80105c13:	85 c0                	test   %eax,%eax
80105c15:	78 19                	js     80105c30 <sys_write+0x4b>
80105c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1a:	83 ec 04             	sub    $0x4,%esp
80105c1d:	50                   	push   %eax
80105c1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105c21:	50                   	push   %eax
80105c22:	6a 01                	push   $0x1
80105c24:	e8 25 fd ff ff       	call   8010594e <argptr>
80105c29:	83 c4 10             	add    $0x10,%esp
80105c2c:	85 c0                	test   %eax,%eax
80105c2e:	79 07                	jns    80105c37 <sys_write+0x52>
    return -1;
80105c30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c35:	eb 17                	jmp    80105c4e <sys_write+0x69>
  return filewrite(f, p, n);
80105c37:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105c3a:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c40:	83 ec 04             	sub    $0x4,%esp
80105c43:	51                   	push   %ecx
80105c44:	52                   	push   %edx
80105c45:	50                   	push   %eax
80105c46:	e8 fd b5 ff ff       	call   80101248 <filewrite>
80105c4b:	83 c4 10             	add    $0x10,%esp
}
80105c4e:	c9                   	leave  
80105c4f:	c3                   	ret    

80105c50 <sys_close>:

int
sys_close(void)
{
80105c50:	55                   	push   %ebp
80105c51:	89 e5                	mov    %esp,%ebp
80105c53:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105c56:	83 ec 04             	sub    $0x4,%esp
80105c59:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c5c:	50                   	push   %eax
80105c5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c60:	50                   	push   %eax
80105c61:	6a 00                	push   $0x0
80105c63:	e8 fa fd ff ff       	call   80105a62 <argfd>
80105c68:	83 c4 10             	add    $0x10,%esp
80105c6b:	85 c0                	test   %eax,%eax
80105c6d:	79 07                	jns    80105c76 <sys_close+0x26>
    return -1;
80105c6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c74:	eb 28                	jmp    80105c9e <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105c76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c7f:	83 c2 08             	add    $0x8,%edx
80105c82:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c89:	00 
  fileclose(f);
80105c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c8d:	83 ec 0c             	sub    $0xc,%esp
80105c90:	50                   	push   %eax
80105c91:	e8 bb b3 ff ff       	call   80101051 <fileclose>
80105c96:	83 c4 10             	add    $0x10,%esp
  return 0;
80105c99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c9e:	c9                   	leave  
80105c9f:	c3                   	ret    

80105ca0 <sys_fstat>:

int
sys_fstat(void)
{
80105ca0:	55                   	push   %ebp
80105ca1:	89 e5                	mov    %esp,%ebp
80105ca3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105ca6:	83 ec 04             	sub    $0x4,%esp
80105ca9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cac:	50                   	push   %eax
80105cad:	6a 00                	push   $0x0
80105caf:	6a 00                	push   $0x0
80105cb1:	e8 ac fd ff ff       	call   80105a62 <argfd>
80105cb6:	83 c4 10             	add    $0x10,%esp
80105cb9:	85 c0                	test   %eax,%eax
80105cbb:	78 17                	js     80105cd4 <sys_fstat+0x34>
80105cbd:	83 ec 04             	sub    $0x4,%esp
80105cc0:	6a 14                	push   $0x14
80105cc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cc5:	50                   	push   %eax
80105cc6:	6a 01                	push   $0x1
80105cc8:	e8 81 fc ff ff       	call   8010594e <argptr>
80105ccd:	83 c4 10             	add    $0x10,%esp
80105cd0:	85 c0                	test   %eax,%eax
80105cd2:	79 07                	jns    80105cdb <sys_fstat+0x3b>
    return -1;
80105cd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd9:	eb 13                	jmp    80105cee <sys_fstat+0x4e>
  return filestat(f, st);
80105cdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce1:	83 ec 08             	sub    $0x8,%esp
80105ce4:	52                   	push   %edx
80105ce5:	50                   	push   %eax
80105ce6:	e8 4e b4 ff ff       	call   80101139 <filestat>
80105ceb:	83 c4 10             	add    $0x10,%esp
}
80105cee:	c9                   	leave  
80105cef:	c3                   	ret    

80105cf0 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105cf0:	55                   	push   %ebp
80105cf1:	89 e5                	mov    %esp,%ebp
80105cf3:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105cf6:	83 ec 08             	sub    $0x8,%esp
80105cf9:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105cfc:	50                   	push   %eax
80105cfd:	6a 00                	push   $0x0
80105cff:	e8 a7 fc ff ff       	call   801059ab <argstr>
80105d04:	83 c4 10             	add    $0x10,%esp
80105d07:	85 c0                	test   %eax,%eax
80105d09:	78 15                	js     80105d20 <sys_link+0x30>
80105d0b:	83 ec 08             	sub    $0x8,%esp
80105d0e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105d11:	50                   	push   %eax
80105d12:	6a 01                	push   $0x1
80105d14:	e8 92 fc ff ff       	call   801059ab <argstr>
80105d19:	83 c4 10             	add    $0x10,%esp
80105d1c:	85 c0                	test   %eax,%eax
80105d1e:	79 0a                	jns    80105d2a <sys_link+0x3a>
    return -1;
80105d20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d25:	e9 68 01 00 00       	jmp    80105e92 <sys_link+0x1a2>

  begin_op();
80105d2a:	e8 1e d8 ff ff       	call   8010354d <begin_op>
  if((ip = namei(old)) == 0){
80105d2f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105d32:	83 ec 0c             	sub    $0xc,%esp
80105d35:	50                   	push   %eax
80105d36:	e8 ed c7 ff ff       	call   80102528 <namei>
80105d3b:	83 c4 10             	add    $0x10,%esp
80105d3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d41:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d45:	75 0f                	jne    80105d56 <sys_link+0x66>
    end_op();
80105d47:	e8 8d d8 ff ff       	call   801035d9 <end_op>
    return -1;
80105d4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d51:	e9 3c 01 00 00       	jmp    80105e92 <sys_link+0x1a2>
  }

  ilock(ip);
80105d56:	83 ec 0c             	sub    $0xc,%esp
80105d59:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5c:	e8 09 bc ff ff       	call   8010196a <ilock>
80105d61:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105d64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d67:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d6b:	66 83 f8 01          	cmp    $0x1,%ax
80105d6f:	75 1d                	jne    80105d8e <sys_link+0x9e>
    iunlockput(ip);
80105d71:	83 ec 0c             	sub    $0xc,%esp
80105d74:	ff 75 f4             	pushl  -0xc(%ebp)
80105d77:	e8 ae be ff ff       	call   80101c2a <iunlockput>
80105d7c:	83 c4 10             	add    $0x10,%esp
    end_op();
80105d7f:	e8 55 d8 ff ff       	call   801035d9 <end_op>
    return -1;
80105d84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d89:	e9 04 01 00 00       	jmp    80105e92 <sys_link+0x1a2>
  }

  ip->nlink++;
80105d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d91:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d95:	83 c0 01             	add    $0x1,%eax
80105d98:	89 c2                	mov    %eax,%edx
80105d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d9d:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105da1:	83 ec 0c             	sub    $0xc,%esp
80105da4:	ff 75 f4             	pushl  -0xc(%ebp)
80105da7:	e8 e4 b9 ff ff       	call   80101790 <iupdate>
80105dac:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105daf:	83 ec 0c             	sub    $0xc,%esp
80105db2:	ff 75 f4             	pushl  -0xc(%ebp)
80105db5:	e8 0e bd ff ff       	call   80101ac8 <iunlock>
80105dba:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105dc0:	83 ec 08             	sub    $0x8,%esp
80105dc3:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105dc6:	52                   	push   %edx
80105dc7:	50                   	push   %eax
80105dc8:	e8 77 c7 ff ff       	call   80102544 <nameiparent>
80105dcd:	83 c4 10             	add    $0x10,%esp
80105dd0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dd3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dd7:	74 71                	je     80105e4a <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105dd9:	83 ec 0c             	sub    $0xc,%esp
80105ddc:	ff 75 f0             	pushl  -0x10(%ebp)
80105ddf:	e8 86 bb ff ff       	call   8010196a <ilock>
80105de4:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dea:	8b 10                	mov    (%eax),%edx
80105dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105def:	8b 00                	mov    (%eax),%eax
80105df1:	39 c2                	cmp    %eax,%edx
80105df3:	75 1d                	jne    80105e12 <sys_link+0x122>
80105df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df8:	8b 40 04             	mov    0x4(%eax),%eax
80105dfb:	83 ec 04             	sub    $0x4,%esp
80105dfe:	50                   	push   %eax
80105dff:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105e02:	50                   	push   %eax
80105e03:	ff 75 f0             	pushl  -0x10(%ebp)
80105e06:	e8 81 c4 ff ff       	call   8010228c <dirlink>
80105e0b:	83 c4 10             	add    $0x10,%esp
80105e0e:	85 c0                	test   %eax,%eax
80105e10:	79 10                	jns    80105e22 <sys_link+0x132>
    iunlockput(dp);
80105e12:	83 ec 0c             	sub    $0xc,%esp
80105e15:	ff 75 f0             	pushl  -0x10(%ebp)
80105e18:	e8 0d be ff ff       	call   80101c2a <iunlockput>
80105e1d:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e20:	eb 29                	jmp    80105e4b <sys_link+0x15b>
  }
  iunlockput(dp);
80105e22:	83 ec 0c             	sub    $0xc,%esp
80105e25:	ff 75 f0             	pushl  -0x10(%ebp)
80105e28:	e8 fd bd ff ff       	call   80101c2a <iunlockput>
80105e2d:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105e30:	83 ec 0c             	sub    $0xc,%esp
80105e33:	ff 75 f4             	pushl  -0xc(%ebp)
80105e36:	e8 ff bc ff ff       	call   80101b3a <iput>
80105e3b:	83 c4 10             	add    $0x10,%esp

  end_op();
80105e3e:	e8 96 d7 ff ff       	call   801035d9 <end_op>

  return 0;
80105e43:	b8 00 00 00 00       	mov    $0x0,%eax
80105e48:	eb 48                	jmp    80105e92 <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105e4a:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105e4b:	83 ec 0c             	sub    $0xc,%esp
80105e4e:	ff 75 f4             	pushl  -0xc(%ebp)
80105e51:	e8 14 bb ff ff       	call   8010196a <ilock>
80105e56:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e5c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e60:	83 e8 01             	sub    $0x1,%eax
80105e63:	89 c2                	mov    %eax,%edx
80105e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e68:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105e6c:	83 ec 0c             	sub    $0xc,%esp
80105e6f:	ff 75 f4             	pushl  -0xc(%ebp)
80105e72:	e8 19 b9 ff ff       	call   80101790 <iupdate>
80105e77:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105e7a:	83 ec 0c             	sub    $0xc,%esp
80105e7d:	ff 75 f4             	pushl  -0xc(%ebp)
80105e80:	e8 a5 bd ff ff       	call   80101c2a <iunlockput>
80105e85:	83 c4 10             	add    $0x10,%esp
  end_op();
80105e88:	e8 4c d7 ff ff       	call   801035d9 <end_op>
  return -1;
80105e8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e92:	c9                   	leave  
80105e93:	c3                   	ret    

80105e94 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105e94:	55                   	push   %ebp
80105e95:	89 e5                	mov    %esp,%ebp
80105e97:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105e9a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ea1:	eb 40                	jmp    80105ee3 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea6:	6a 10                	push   $0x10
80105ea8:	50                   	push   %eax
80105ea9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105eac:	50                   	push   %eax
80105ead:	ff 75 08             	pushl  0x8(%ebp)
80105eb0:	e8 23 c0 ff ff       	call   80101ed8 <readi>
80105eb5:	83 c4 10             	add    $0x10,%esp
80105eb8:	83 f8 10             	cmp    $0x10,%eax
80105ebb:	74 0d                	je     80105eca <isdirempty+0x36>
      panic("isdirempty: readi");
80105ebd:	83 ec 0c             	sub    $0xc,%esp
80105ec0:	68 cf 8e 10 80       	push   $0x80108ecf
80105ec5:	e8 9c a6 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105eca:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105ece:	66 85 c0             	test   %ax,%ax
80105ed1:	74 07                	je     80105eda <isdirempty+0x46>
      return 0;
80105ed3:	b8 00 00 00 00       	mov    $0x0,%eax
80105ed8:	eb 1b                	jmp    80105ef5 <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edd:	83 c0 10             	add    $0x10,%eax
80105ee0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee6:	8b 50 18             	mov    0x18(%eax),%edx
80105ee9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eec:	39 c2                	cmp    %eax,%edx
80105eee:	77 b3                	ja     80105ea3 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105ef0:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ef5:	c9                   	leave  
80105ef6:	c3                   	ret    

80105ef7 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ef7:	55                   	push   %ebp
80105ef8:	89 e5                	mov    %esp,%ebp
80105efa:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105efd:	83 ec 08             	sub    $0x8,%esp
80105f00:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105f03:	50                   	push   %eax
80105f04:	6a 00                	push   $0x0
80105f06:	e8 a0 fa ff ff       	call   801059ab <argstr>
80105f0b:	83 c4 10             	add    $0x10,%esp
80105f0e:	85 c0                	test   %eax,%eax
80105f10:	79 0a                	jns    80105f1c <sys_unlink+0x25>
    return -1;
80105f12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f17:	e9 bc 01 00 00       	jmp    801060d8 <sys_unlink+0x1e1>

  begin_op();
80105f1c:	e8 2c d6 ff ff       	call   8010354d <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105f21:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105f24:	83 ec 08             	sub    $0x8,%esp
80105f27:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105f2a:	52                   	push   %edx
80105f2b:	50                   	push   %eax
80105f2c:	e8 13 c6 ff ff       	call   80102544 <nameiparent>
80105f31:	83 c4 10             	add    $0x10,%esp
80105f34:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f37:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f3b:	75 0f                	jne    80105f4c <sys_unlink+0x55>
    end_op();
80105f3d:	e8 97 d6 ff ff       	call   801035d9 <end_op>
    return -1;
80105f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f47:	e9 8c 01 00 00       	jmp    801060d8 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105f4c:	83 ec 0c             	sub    $0xc,%esp
80105f4f:	ff 75 f4             	pushl  -0xc(%ebp)
80105f52:	e8 13 ba ff ff       	call   8010196a <ilock>
80105f57:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105f5a:	83 ec 08             	sub    $0x8,%esp
80105f5d:	68 e1 8e 10 80       	push   $0x80108ee1
80105f62:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f65:	50                   	push   %eax
80105f66:	e8 4c c2 ff ff       	call   801021b7 <namecmp>
80105f6b:	83 c4 10             	add    $0x10,%esp
80105f6e:	85 c0                	test   %eax,%eax
80105f70:	0f 84 4a 01 00 00    	je     801060c0 <sys_unlink+0x1c9>
80105f76:	83 ec 08             	sub    $0x8,%esp
80105f79:	68 e3 8e 10 80       	push   $0x80108ee3
80105f7e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f81:	50                   	push   %eax
80105f82:	e8 30 c2 ff ff       	call   801021b7 <namecmp>
80105f87:	83 c4 10             	add    $0x10,%esp
80105f8a:	85 c0                	test   %eax,%eax
80105f8c:	0f 84 2e 01 00 00    	je     801060c0 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105f92:	83 ec 04             	sub    $0x4,%esp
80105f95:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105f98:	50                   	push   %eax
80105f99:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105f9c:	50                   	push   %eax
80105f9d:	ff 75 f4             	pushl  -0xc(%ebp)
80105fa0:	e8 2d c2 ff ff       	call   801021d2 <dirlookup>
80105fa5:	83 c4 10             	add    $0x10,%esp
80105fa8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105faf:	0f 84 0a 01 00 00    	je     801060bf <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105fb5:	83 ec 0c             	sub    $0xc,%esp
80105fb8:	ff 75 f0             	pushl  -0x10(%ebp)
80105fbb:	e8 aa b9 ff ff       	call   8010196a <ilock>
80105fc0:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105fc3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc6:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105fca:	66 85 c0             	test   %ax,%ax
80105fcd:	7f 0d                	jg     80105fdc <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105fcf:	83 ec 0c             	sub    $0xc,%esp
80105fd2:	68 e6 8e 10 80       	push   $0x80108ee6
80105fd7:	e8 8a a5 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdf:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105fe3:	66 83 f8 01          	cmp    $0x1,%ax
80105fe7:	75 25                	jne    8010600e <sys_unlink+0x117>
80105fe9:	83 ec 0c             	sub    $0xc,%esp
80105fec:	ff 75 f0             	pushl  -0x10(%ebp)
80105fef:	e8 a0 fe ff ff       	call   80105e94 <isdirempty>
80105ff4:	83 c4 10             	add    $0x10,%esp
80105ff7:	85 c0                	test   %eax,%eax
80105ff9:	75 13                	jne    8010600e <sys_unlink+0x117>
    iunlockput(ip);
80105ffb:	83 ec 0c             	sub    $0xc,%esp
80105ffe:	ff 75 f0             	pushl  -0x10(%ebp)
80106001:	e8 24 bc ff ff       	call   80101c2a <iunlockput>
80106006:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106009:	e9 b2 00 00 00       	jmp    801060c0 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
8010600e:	83 ec 04             	sub    $0x4,%esp
80106011:	6a 10                	push   $0x10
80106013:	6a 00                	push   $0x0
80106015:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106018:	50                   	push   %eax
80106019:	e8 e3 f5 ff ff       	call   80105601 <memset>
8010601e:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106021:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106024:	6a 10                	push   $0x10
80106026:	50                   	push   %eax
80106027:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010602a:	50                   	push   %eax
8010602b:	ff 75 f4             	pushl  -0xc(%ebp)
8010602e:	e8 fc bf ff ff       	call   8010202f <writei>
80106033:	83 c4 10             	add    $0x10,%esp
80106036:	83 f8 10             	cmp    $0x10,%eax
80106039:	74 0d                	je     80106048 <sys_unlink+0x151>
    panic("unlink: writei");
8010603b:	83 ec 0c             	sub    $0xc,%esp
8010603e:	68 f8 8e 10 80       	push   $0x80108ef8
80106043:	e8 1e a5 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106048:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010604b:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010604f:	66 83 f8 01          	cmp    $0x1,%ax
80106053:	75 21                	jne    80106076 <sys_unlink+0x17f>
    dp->nlink--;
80106055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106058:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010605c:	83 e8 01             	sub    $0x1,%eax
8010605f:	89 c2                	mov    %eax,%edx
80106061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106064:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106068:	83 ec 0c             	sub    $0xc,%esp
8010606b:	ff 75 f4             	pushl  -0xc(%ebp)
8010606e:	e8 1d b7 ff ff       	call   80101790 <iupdate>
80106073:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106076:	83 ec 0c             	sub    $0xc,%esp
80106079:	ff 75 f4             	pushl  -0xc(%ebp)
8010607c:	e8 a9 bb ff ff       	call   80101c2a <iunlockput>
80106081:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106084:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106087:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010608b:	83 e8 01             	sub    $0x1,%eax
8010608e:	89 c2                	mov    %eax,%edx
80106090:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106093:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106097:	83 ec 0c             	sub    $0xc,%esp
8010609a:	ff 75 f0             	pushl  -0x10(%ebp)
8010609d:	e8 ee b6 ff ff       	call   80101790 <iupdate>
801060a2:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801060a5:	83 ec 0c             	sub    $0xc,%esp
801060a8:	ff 75 f0             	pushl  -0x10(%ebp)
801060ab:	e8 7a bb ff ff       	call   80101c2a <iunlockput>
801060b0:	83 c4 10             	add    $0x10,%esp

  end_op();
801060b3:	e8 21 d5 ff ff       	call   801035d9 <end_op>

  return 0;
801060b8:	b8 00 00 00 00       	mov    $0x0,%eax
801060bd:	eb 19                	jmp    801060d8 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801060bf:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801060c0:	83 ec 0c             	sub    $0xc,%esp
801060c3:	ff 75 f4             	pushl  -0xc(%ebp)
801060c6:	e8 5f bb ff ff       	call   80101c2a <iunlockput>
801060cb:	83 c4 10             	add    $0x10,%esp
  end_op();
801060ce:	e8 06 d5 ff ff       	call   801035d9 <end_op>
  return -1;
801060d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060d8:	c9                   	leave  
801060d9:	c3                   	ret    

801060da <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801060da:	55                   	push   %ebp
801060db:	89 e5                	mov    %esp,%ebp
801060dd:	83 ec 38             	sub    $0x38,%esp
801060e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801060e3:	8b 55 10             	mov    0x10(%ebp),%edx
801060e6:	8b 45 14             	mov    0x14(%ebp),%eax
801060e9:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801060ed:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801060f1:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801060f5:	83 ec 08             	sub    $0x8,%esp
801060f8:	8d 45 de             	lea    -0x22(%ebp),%eax
801060fb:	50                   	push   %eax
801060fc:	ff 75 08             	pushl  0x8(%ebp)
801060ff:	e8 40 c4 ff ff       	call   80102544 <nameiparent>
80106104:	83 c4 10             	add    $0x10,%esp
80106107:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010610a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010610e:	75 0a                	jne    8010611a <create+0x40>
    return 0;
80106110:	b8 00 00 00 00       	mov    $0x0,%eax
80106115:	e9 90 01 00 00       	jmp    801062aa <create+0x1d0>
  ilock(dp);
8010611a:	83 ec 0c             	sub    $0xc,%esp
8010611d:	ff 75 f4             	pushl  -0xc(%ebp)
80106120:	e8 45 b8 ff ff       	call   8010196a <ilock>
80106125:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106128:	83 ec 04             	sub    $0x4,%esp
8010612b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010612e:	50                   	push   %eax
8010612f:	8d 45 de             	lea    -0x22(%ebp),%eax
80106132:	50                   	push   %eax
80106133:	ff 75 f4             	pushl  -0xc(%ebp)
80106136:	e8 97 c0 ff ff       	call   801021d2 <dirlookup>
8010613b:	83 c4 10             	add    $0x10,%esp
8010613e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106141:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106145:	74 50                	je     80106197 <create+0xbd>
    iunlockput(dp);
80106147:	83 ec 0c             	sub    $0xc,%esp
8010614a:	ff 75 f4             	pushl  -0xc(%ebp)
8010614d:	e8 d8 ba ff ff       	call   80101c2a <iunlockput>
80106152:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106155:	83 ec 0c             	sub    $0xc,%esp
80106158:	ff 75 f0             	pushl  -0x10(%ebp)
8010615b:	e8 0a b8 ff ff       	call   8010196a <ilock>
80106160:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106163:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106168:	75 15                	jne    8010617f <create+0xa5>
8010616a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010616d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106171:	66 83 f8 02          	cmp    $0x2,%ax
80106175:	75 08                	jne    8010617f <create+0xa5>
      return ip;
80106177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010617a:	e9 2b 01 00 00       	jmp    801062aa <create+0x1d0>
    iunlockput(ip);
8010617f:	83 ec 0c             	sub    $0xc,%esp
80106182:	ff 75 f0             	pushl  -0x10(%ebp)
80106185:	e8 a0 ba ff ff       	call   80101c2a <iunlockput>
8010618a:	83 c4 10             	add    $0x10,%esp
    return 0;
8010618d:	b8 00 00 00 00       	mov    $0x0,%eax
80106192:	e9 13 01 00 00       	jmp    801062aa <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106197:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010619b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619e:	8b 00                	mov    (%eax),%eax
801061a0:	83 ec 08             	sub    $0x8,%esp
801061a3:	52                   	push   %edx
801061a4:	50                   	push   %eax
801061a5:	e8 0f b5 ff ff       	call   801016b9 <ialloc>
801061aa:	83 c4 10             	add    $0x10,%esp
801061ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061b4:	75 0d                	jne    801061c3 <create+0xe9>
    panic("create: ialloc");
801061b6:	83 ec 0c             	sub    $0xc,%esp
801061b9:	68 07 8f 10 80       	push   $0x80108f07
801061be:	e8 a3 a3 ff ff       	call   80100566 <panic>

  ilock(ip);
801061c3:	83 ec 0c             	sub    $0xc,%esp
801061c6:	ff 75 f0             	pushl  -0x10(%ebp)
801061c9:	e8 9c b7 ff ff       	call   8010196a <ilock>
801061ce:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801061d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d4:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801061d8:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801061dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061df:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801061e3:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801061e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ea:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801061f0:	83 ec 0c             	sub    $0xc,%esp
801061f3:	ff 75 f0             	pushl  -0x10(%ebp)
801061f6:	e8 95 b5 ff ff       	call   80101790 <iupdate>
801061fb:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801061fe:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106203:	75 6a                	jne    8010626f <create+0x195>
    dp->nlink++;  // for ".."
80106205:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106208:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010620c:	83 c0 01             	add    $0x1,%eax
8010620f:	89 c2                	mov    %eax,%edx
80106211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106214:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106218:	83 ec 0c             	sub    $0xc,%esp
8010621b:	ff 75 f4             	pushl  -0xc(%ebp)
8010621e:	e8 6d b5 ff ff       	call   80101790 <iupdate>
80106223:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106226:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106229:	8b 40 04             	mov    0x4(%eax),%eax
8010622c:	83 ec 04             	sub    $0x4,%esp
8010622f:	50                   	push   %eax
80106230:	68 e1 8e 10 80       	push   $0x80108ee1
80106235:	ff 75 f0             	pushl  -0x10(%ebp)
80106238:	e8 4f c0 ff ff       	call   8010228c <dirlink>
8010623d:	83 c4 10             	add    $0x10,%esp
80106240:	85 c0                	test   %eax,%eax
80106242:	78 1e                	js     80106262 <create+0x188>
80106244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106247:	8b 40 04             	mov    0x4(%eax),%eax
8010624a:	83 ec 04             	sub    $0x4,%esp
8010624d:	50                   	push   %eax
8010624e:	68 e3 8e 10 80       	push   $0x80108ee3
80106253:	ff 75 f0             	pushl  -0x10(%ebp)
80106256:	e8 31 c0 ff ff       	call   8010228c <dirlink>
8010625b:	83 c4 10             	add    $0x10,%esp
8010625e:	85 c0                	test   %eax,%eax
80106260:	79 0d                	jns    8010626f <create+0x195>
      panic("create dots");
80106262:	83 ec 0c             	sub    $0xc,%esp
80106265:	68 16 8f 10 80       	push   $0x80108f16
8010626a:	e8 f7 a2 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010626f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106272:	8b 40 04             	mov    0x4(%eax),%eax
80106275:	83 ec 04             	sub    $0x4,%esp
80106278:	50                   	push   %eax
80106279:	8d 45 de             	lea    -0x22(%ebp),%eax
8010627c:	50                   	push   %eax
8010627d:	ff 75 f4             	pushl  -0xc(%ebp)
80106280:	e8 07 c0 ff ff       	call   8010228c <dirlink>
80106285:	83 c4 10             	add    $0x10,%esp
80106288:	85 c0                	test   %eax,%eax
8010628a:	79 0d                	jns    80106299 <create+0x1bf>
    panic("create: dirlink");
8010628c:	83 ec 0c             	sub    $0xc,%esp
8010628f:	68 22 8f 10 80       	push   $0x80108f22
80106294:	e8 cd a2 ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106299:	83 ec 0c             	sub    $0xc,%esp
8010629c:	ff 75 f4             	pushl  -0xc(%ebp)
8010629f:	e8 86 b9 ff ff       	call   80101c2a <iunlockput>
801062a4:	83 c4 10             	add    $0x10,%esp

  return ip;
801062a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801062aa:	c9                   	leave  
801062ab:	c3                   	ret    

801062ac <sys_open>:

int
sys_open(void)
{
801062ac:	55                   	push   %ebp
801062ad:	89 e5                	mov    %esp,%ebp
801062af:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801062b2:	83 ec 08             	sub    $0x8,%esp
801062b5:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062b8:	50                   	push   %eax
801062b9:	6a 00                	push   $0x0
801062bb:	e8 eb f6 ff ff       	call   801059ab <argstr>
801062c0:	83 c4 10             	add    $0x10,%esp
801062c3:	85 c0                	test   %eax,%eax
801062c5:	78 15                	js     801062dc <sys_open+0x30>
801062c7:	83 ec 08             	sub    $0x8,%esp
801062ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062cd:	50                   	push   %eax
801062ce:	6a 01                	push   $0x1
801062d0:	e8 51 f6 ff ff       	call   80105926 <argint>
801062d5:	83 c4 10             	add    $0x10,%esp
801062d8:	85 c0                	test   %eax,%eax
801062da:	79 0a                	jns    801062e6 <sys_open+0x3a>
    return -1;
801062dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e1:	e9 61 01 00 00       	jmp    80106447 <sys_open+0x19b>

  begin_op();
801062e6:	e8 62 d2 ff ff       	call   8010354d <begin_op>

  if(omode & O_CREATE){
801062eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062ee:	25 00 02 00 00       	and    $0x200,%eax
801062f3:	85 c0                	test   %eax,%eax
801062f5:	74 2a                	je     80106321 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801062f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062fa:	6a 00                	push   $0x0
801062fc:	6a 00                	push   $0x0
801062fe:	6a 02                	push   $0x2
80106300:	50                   	push   %eax
80106301:	e8 d4 fd ff ff       	call   801060da <create>
80106306:	83 c4 10             	add    $0x10,%esp
80106309:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010630c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106310:	75 75                	jne    80106387 <sys_open+0xdb>
      end_op();
80106312:	e8 c2 d2 ff ff       	call   801035d9 <end_op>
      return -1;
80106317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631c:	e9 26 01 00 00       	jmp    80106447 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80106321:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106324:	83 ec 0c             	sub    $0xc,%esp
80106327:	50                   	push   %eax
80106328:	e8 fb c1 ff ff       	call   80102528 <namei>
8010632d:	83 c4 10             	add    $0x10,%esp
80106330:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106333:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106337:	75 0f                	jne    80106348 <sys_open+0x9c>
      end_op();
80106339:	e8 9b d2 ff ff       	call   801035d9 <end_op>
      return -1;
8010633e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106343:	e9 ff 00 00 00       	jmp    80106447 <sys_open+0x19b>
    }
    ilock(ip);
80106348:	83 ec 0c             	sub    $0xc,%esp
8010634b:	ff 75 f4             	pushl  -0xc(%ebp)
8010634e:	e8 17 b6 ff ff       	call   8010196a <ilock>
80106353:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106359:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010635d:	66 83 f8 01          	cmp    $0x1,%ax
80106361:	75 24                	jne    80106387 <sys_open+0xdb>
80106363:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106366:	85 c0                	test   %eax,%eax
80106368:	74 1d                	je     80106387 <sys_open+0xdb>
      iunlockput(ip);
8010636a:	83 ec 0c             	sub    $0xc,%esp
8010636d:	ff 75 f4             	pushl  -0xc(%ebp)
80106370:	e8 b5 b8 ff ff       	call   80101c2a <iunlockput>
80106375:	83 c4 10             	add    $0x10,%esp
      end_op();
80106378:	e8 5c d2 ff ff       	call   801035d9 <end_op>
      return -1;
8010637d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106382:	e9 c0 00 00 00       	jmp    80106447 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106387:	e8 07 ac ff ff       	call   80100f93 <filealloc>
8010638c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010638f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106393:	74 17                	je     801063ac <sys_open+0x100>
80106395:	83 ec 0c             	sub    $0xc,%esp
80106398:	ff 75 f0             	pushl  -0x10(%ebp)
8010639b:	e8 37 f7 ff ff       	call   80105ad7 <fdalloc>
801063a0:	83 c4 10             	add    $0x10,%esp
801063a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801063a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801063aa:	79 2e                	jns    801063da <sys_open+0x12e>
    if(f)
801063ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063b0:	74 0e                	je     801063c0 <sys_open+0x114>
      fileclose(f);
801063b2:	83 ec 0c             	sub    $0xc,%esp
801063b5:	ff 75 f0             	pushl  -0x10(%ebp)
801063b8:	e8 94 ac ff ff       	call   80101051 <fileclose>
801063bd:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801063c0:	83 ec 0c             	sub    $0xc,%esp
801063c3:	ff 75 f4             	pushl  -0xc(%ebp)
801063c6:	e8 5f b8 ff ff       	call   80101c2a <iunlockput>
801063cb:	83 c4 10             	add    $0x10,%esp
    end_op();
801063ce:	e8 06 d2 ff ff       	call   801035d9 <end_op>
    return -1;
801063d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063d8:	eb 6d                	jmp    80106447 <sys_open+0x19b>
  }
  iunlock(ip);
801063da:	83 ec 0c             	sub    $0xc,%esp
801063dd:	ff 75 f4             	pushl  -0xc(%ebp)
801063e0:	e8 e3 b6 ff ff       	call   80101ac8 <iunlock>
801063e5:	83 c4 10             	add    $0x10,%esp
  end_op();
801063e8:	e8 ec d1 ff ff       	call   801035d9 <end_op>

  f->type = FD_INODE;
801063ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801063f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063fc:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801063ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106402:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106409:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010640c:	83 e0 01             	and    $0x1,%eax
8010640f:	85 c0                	test   %eax,%eax
80106411:	0f 94 c0             	sete   %al
80106414:	89 c2                	mov    %eax,%edx
80106416:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106419:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010641c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010641f:	83 e0 01             	and    $0x1,%eax
80106422:	85 c0                	test   %eax,%eax
80106424:	75 0a                	jne    80106430 <sys_open+0x184>
80106426:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106429:	83 e0 02             	and    $0x2,%eax
8010642c:	85 c0                	test   %eax,%eax
8010642e:	74 07                	je     80106437 <sys_open+0x18b>
80106430:	b8 01 00 00 00       	mov    $0x1,%eax
80106435:	eb 05                	jmp    8010643c <sys_open+0x190>
80106437:	b8 00 00 00 00       	mov    $0x0,%eax
8010643c:	89 c2                	mov    %eax,%edx
8010643e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106441:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106444:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106447:	c9                   	leave  
80106448:	c3                   	ret    

80106449 <sys_mkdir>:

int
sys_mkdir(void)
{
80106449:	55                   	push   %ebp
8010644a:	89 e5                	mov    %esp,%ebp
8010644c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010644f:	e8 f9 d0 ff ff       	call   8010354d <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106454:	83 ec 08             	sub    $0x8,%esp
80106457:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010645a:	50                   	push   %eax
8010645b:	6a 00                	push   $0x0
8010645d:	e8 49 f5 ff ff       	call   801059ab <argstr>
80106462:	83 c4 10             	add    $0x10,%esp
80106465:	85 c0                	test   %eax,%eax
80106467:	78 1b                	js     80106484 <sys_mkdir+0x3b>
80106469:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010646c:	6a 00                	push   $0x0
8010646e:	6a 00                	push   $0x0
80106470:	6a 01                	push   $0x1
80106472:	50                   	push   %eax
80106473:	e8 62 fc ff ff       	call   801060da <create>
80106478:	83 c4 10             	add    $0x10,%esp
8010647b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010647e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106482:	75 0c                	jne    80106490 <sys_mkdir+0x47>
    end_op();
80106484:	e8 50 d1 ff ff       	call   801035d9 <end_op>
    return -1;
80106489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648e:	eb 18                	jmp    801064a8 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106490:	83 ec 0c             	sub    $0xc,%esp
80106493:	ff 75 f4             	pushl  -0xc(%ebp)
80106496:	e8 8f b7 ff ff       	call   80101c2a <iunlockput>
8010649b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010649e:	e8 36 d1 ff ff       	call   801035d9 <end_op>
  return 0;
801064a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064a8:	c9                   	leave  
801064a9:	c3                   	ret    

801064aa <sys_mknod>:

int
sys_mknod(void)
{
801064aa:	55                   	push   %ebp
801064ab:	89 e5                	mov    %esp,%ebp
801064ad:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801064b0:	e8 98 d0 ff ff       	call   8010354d <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801064b5:	83 ec 08             	sub    $0x8,%esp
801064b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064bb:	50                   	push   %eax
801064bc:	6a 00                	push   $0x0
801064be:	e8 e8 f4 ff ff       	call   801059ab <argstr>
801064c3:	83 c4 10             	add    $0x10,%esp
801064c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064c9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064cd:	78 4f                	js     8010651e <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801064cf:	83 ec 08             	sub    $0x8,%esp
801064d2:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064d5:	50                   	push   %eax
801064d6:	6a 01                	push   $0x1
801064d8:	e8 49 f4 ff ff       	call   80105926 <argint>
801064dd:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801064e0:	85 c0                	test   %eax,%eax
801064e2:	78 3a                	js     8010651e <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801064e4:	83 ec 08             	sub    $0x8,%esp
801064e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064ea:	50                   	push   %eax
801064eb:	6a 02                	push   $0x2
801064ed:	e8 34 f4 ff ff       	call   80105926 <argint>
801064f2:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801064f5:	85 c0                	test   %eax,%eax
801064f7:	78 25                	js     8010651e <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801064f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064fc:	0f bf c8             	movswl %ax,%ecx
801064ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106502:	0f bf d0             	movswl %ax,%edx
80106505:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106508:	51                   	push   %ecx
80106509:	52                   	push   %edx
8010650a:	6a 03                	push   $0x3
8010650c:	50                   	push   %eax
8010650d:	e8 c8 fb ff ff       	call   801060da <create>
80106512:	83 c4 10             	add    $0x10,%esp
80106515:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106518:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010651c:	75 0c                	jne    8010652a <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010651e:	e8 b6 d0 ff ff       	call   801035d9 <end_op>
    return -1;
80106523:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106528:	eb 18                	jmp    80106542 <sys_mknod+0x98>
  }
  iunlockput(ip);
8010652a:	83 ec 0c             	sub    $0xc,%esp
8010652d:	ff 75 f0             	pushl  -0x10(%ebp)
80106530:	e8 f5 b6 ff ff       	call   80101c2a <iunlockput>
80106535:	83 c4 10             	add    $0x10,%esp
  end_op();
80106538:	e8 9c d0 ff ff       	call   801035d9 <end_op>
  return 0;
8010653d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106542:	c9                   	leave  
80106543:	c3                   	ret    

80106544 <sys_chdir>:

int
sys_chdir(void)
{
80106544:	55                   	push   %ebp
80106545:	89 e5                	mov    %esp,%ebp
80106547:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010654a:	e8 fe cf ff ff       	call   8010354d <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010654f:	83 ec 08             	sub    $0x8,%esp
80106552:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106555:	50                   	push   %eax
80106556:	6a 00                	push   $0x0
80106558:	e8 4e f4 ff ff       	call   801059ab <argstr>
8010655d:	83 c4 10             	add    $0x10,%esp
80106560:	85 c0                	test   %eax,%eax
80106562:	78 18                	js     8010657c <sys_chdir+0x38>
80106564:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106567:	83 ec 0c             	sub    $0xc,%esp
8010656a:	50                   	push   %eax
8010656b:	e8 b8 bf ff ff       	call   80102528 <namei>
80106570:	83 c4 10             	add    $0x10,%esp
80106573:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106576:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010657a:	75 0c                	jne    80106588 <sys_chdir+0x44>
    end_op();
8010657c:	e8 58 d0 ff ff       	call   801035d9 <end_op>
    return -1;
80106581:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106586:	eb 6e                	jmp    801065f6 <sys_chdir+0xb2>
  }
  ilock(ip);
80106588:	83 ec 0c             	sub    $0xc,%esp
8010658b:	ff 75 f4             	pushl  -0xc(%ebp)
8010658e:	e8 d7 b3 ff ff       	call   8010196a <ilock>
80106593:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106599:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010659d:	66 83 f8 01          	cmp    $0x1,%ax
801065a1:	74 1a                	je     801065bd <sys_chdir+0x79>
    iunlockput(ip);
801065a3:	83 ec 0c             	sub    $0xc,%esp
801065a6:	ff 75 f4             	pushl  -0xc(%ebp)
801065a9:	e8 7c b6 ff ff       	call   80101c2a <iunlockput>
801065ae:	83 c4 10             	add    $0x10,%esp
    end_op();
801065b1:	e8 23 d0 ff ff       	call   801035d9 <end_op>
    return -1;
801065b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065bb:	eb 39                	jmp    801065f6 <sys_chdir+0xb2>
  }
  iunlock(ip);
801065bd:	83 ec 0c             	sub    $0xc,%esp
801065c0:	ff 75 f4             	pushl  -0xc(%ebp)
801065c3:	e8 00 b5 ff ff       	call   80101ac8 <iunlock>
801065c8:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801065cb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065d1:	8b 40 68             	mov    0x68(%eax),%eax
801065d4:	83 ec 0c             	sub    $0xc,%esp
801065d7:	50                   	push   %eax
801065d8:	e8 5d b5 ff ff       	call   80101b3a <iput>
801065dd:	83 c4 10             	add    $0x10,%esp
  end_op();
801065e0:	e8 f4 cf ff ff       	call   801035d9 <end_op>
  proc->cwd = ip;
801065e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065ee:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801065f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065f6:	c9                   	leave  
801065f7:	c3                   	ret    

801065f8 <sys_exec>:

int
sys_exec(void)
{
801065f8:	55                   	push   %ebp
801065f9:	89 e5                	mov    %esp,%ebp
801065fb:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106601:	83 ec 08             	sub    $0x8,%esp
80106604:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106607:	50                   	push   %eax
80106608:	6a 00                	push   $0x0
8010660a:	e8 9c f3 ff ff       	call   801059ab <argstr>
8010660f:	83 c4 10             	add    $0x10,%esp
80106612:	85 c0                	test   %eax,%eax
80106614:	78 18                	js     8010662e <sys_exec+0x36>
80106616:	83 ec 08             	sub    $0x8,%esp
80106619:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010661f:	50                   	push   %eax
80106620:	6a 01                	push   $0x1
80106622:	e8 ff f2 ff ff       	call   80105926 <argint>
80106627:	83 c4 10             	add    $0x10,%esp
8010662a:	85 c0                	test   %eax,%eax
8010662c:	79 0a                	jns    80106638 <sys_exec+0x40>
    return -1;
8010662e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106633:	e9 c6 00 00 00       	jmp    801066fe <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106638:	83 ec 04             	sub    $0x4,%esp
8010663b:	68 80 00 00 00       	push   $0x80
80106640:	6a 00                	push   $0x0
80106642:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106648:	50                   	push   %eax
80106649:	e8 b3 ef ff ff       	call   80105601 <memset>
8010664e:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106651:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106658:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010665b:	83 f8 1f             	cmp    $0x1f,%eax
8010665e:	76 0a                	jbe    8010666a <sys_exec+0x72>
      return -1;
80106660:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106665:	e9 94 00 00 00       	jmp    801066fe <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010666a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010666d:	c1 e0 02             	shl    $0x2,%eax
80106670:	89 c2                	mov    %eax,%edx
80106672:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106678:	01 c2                	add    %eax,%edx
8010667a:	83 ec 08             	sub    $0x8,%esp
8010667d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106683:	50                   	push   %eax
80106684:	52                   	push   %edx
80106685:	e8 00 f2 ff ff       	call   8010588a <fetchint>
8010668a:	83 c4 10             	add    $0x10,%esp
8010668d:	85 c0                	test   %eax,%eax
8010668f:	79 07                	jns    80106698 <sys_exec+0xa0>
      return -1;
80106691:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106696:	eb 66                	jmp    801066fe <sys_exec+0x106>
    if(uarg == 0){
80106698:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010669e:	85 c0                	test   %eax,%eax
801066a0:	75 27                	jne    801066c9 <sys_exec+0xd1>
      argv[i] = 0;
801066a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066a5:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801066ac:	00 00 00 00 
      break;
801066b0:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801066b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066b4:	83 ec 08             	sub    $0x8,%esp
801066b7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801066bd:	52                   	push   %edx
801066be:	50                   	push   %eax
801066bf:	e8 ad a4 ff ff       	call   80100b71 <exec>
801066c4:	83 c4 10             	add    $0x10,%esp
801066c7:	eb 35                	jmp    801066fe <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801066c9:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801066cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801066d2:	c1 e2 02             	shl    $0x2,%edx
801066d5:	01 c2                	add    %eax,%edx
801066d7:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801066dd:	83 ec 08             	sub    $0x8,%esp
801066e0:	52                   	push   %edx
801066e1:	50                   	push   %eax
801066e2:	e8 dd f1 ff ff       	call   801058c4 <fetchstr>
801066e7:	83 c4 10             	add    $0x10,%esp
801066ea:	85 c0                	test   %eax,%eax
801066ec:	79 07                	jns    801066f5 <sys_exec+0xfd>
      return -1;
801066ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f3:	eb 09                	jmp    801066fe <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801066f5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801066f9:	e9 5a ff ff ff       	jmp    80106658 <sys_exec+0x60>
  return exec(path, argv);
}
801066fe:	c9                   	leave  
801066ff:	c3                   	ret    

80106700 <sys_pipe>:

int
sys_pipe(void)
{
80106700:	55                   	push   %ebp
80106701:	89 e5                	mov    %esp,%ebp
80106703:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106706:	83 ec 04             	sub    $0x4,%esp
80106709:	6a 08                	push   $0x8
8010670b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010670e:	50                   	push   %eax
8010670f:	6a 00                	push   $0x0
80106711:	e8 38 f2 ff ff       	call   8010594e <argptr>
80106716:	83 c4 10             	add    $0x10,%esp
80106719:	85 c0                	test   %eax,%eax
8010671b:	79 0a                	jns    80106727 <sys_pipe+0x27>
    return -1;
8010671d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106722:	e9 af 00 00 00       	jmp    801067d6 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106727:	83 ec 08             	sub    $0x8,%esp
8010672a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010672d:	50                   	push   %eax
8010672e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106731:	50                   	push   %eax
80106732:	e8 0a d9 ff ff       	call   80104041 <pipealloc>
80106737:	83 c4 10             	add    $0x10,%esp
8010673a:	85 c0                	test   %eax,%eax
8010673c:	79 0a                	jns    80106748 <sys_pipe+0x48>
    return -1;
8010673e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106743:	e9 8e 00 00 00       	jmp    801067d6 <sys_pipe+0xd6>
  fd0 = -1;
80106748:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010674f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106752:	83 ec 0c             	sub    $0xc,%esp
80106755:	50                   	push   %eax
80106756:	e8 7c f3 ff ff       	call   80105ad7 <fdalloc>
8010675b:	83 c4 10             	add    $0x10,%esp
8010675e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106761:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106765:	78 18                	js     8010677f <sys_pipe+0x7f>
80106767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010676a:	83 ec 0c             	sub    $0xc,%esp
8010676d:	50                   	push   %eax
8010676e:	e8 64 f3 ff ff       	call   80105ad7 <fdalloc>
80106773:	83 c4 10             	add    $0x10,%esp
80106776:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106779:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010677d:	79 3f                	jns    801067be <sys_pipe+0xbe>
    if(fd0 >= 0)
8010677f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106783:	78 14                	js     80106799 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106785:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010678b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010678e:	83 c2 08             	add    $0x8,%edx
80106791:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106798:	00 
    fileclose(rf);
80106799:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010679c:	83 ec 0c             	sub    $0xc,%esp
8010679f:	50                   	push   %eax
801067a0:	e8 ac a8 ff ff       	call   80101051 <fileclose>
801067a5:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801067a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067ab:	83 ec 0c             	sub    $0xc,%esp
801067ae:	50                   	push   %eax
801067af:	e8 9d a8 ff ff       	call   80101051 <fileclose>
801067b4:	83 c4 10             	add    $0x10,%esp
    return -1;
801067b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067bc:	eb 18                	jmp    801067d6 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801067be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067c4:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801067c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801067c9:	8d 50 04             	lea    0x4(%eax),%edx
801067cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067cf:	89 02                	mov    %eax,(%edx)
  return 0;
801067d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067d6:	c9                   	leave  
801067d7:	c3                   	ret    

801067d8 <outw>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outw(ushort port, ushort data)
{
801067d8:	55                   	push   %ebp
801067d9:	89 e5                	mov    %esp,%ebp
801067db:	83 ec 08             	sub    $0x8,%esp
801067de:	8b 55 08             	mov    0x8(%ebp),%edx
801067e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801067e4:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801067e8:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067ec:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
801067f0:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801067f4:	66 ef                	out    %ax,(%dx)
}
801067f6:	90                   	nop
801067f7:	c9                   	leave  
801067f8:	c3                   	ret    

801067f9 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801067f9:	55                   	push   %ebp
801067fa:	89 e5                	mov    %esp,%ebp
801067fc:	83 ec 08             	sub    $0x8,%esp
  return fork();
801067ff:	e8 8c df ff ff       	call   80104790 <fork>
}
80106804:	c9                   	leave  
80106805:	c3                   	ret    

80106806 <sys_exit>:

int
sys_exit(void)
{
80106806:	55                   	push   %ebp
80106807:	89 e5                	mov    %esp,%ebp
80106809:	83 ec 08             	sub    $0x8,%esp
  exit();
8010680c:	e8 3a e1 ff ff       	call   8010494b <exit>
  return 0;  // not reached
80106811:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106816:	c9                   	leave  
80106817:	c3                   	ret    

80106818 <sys_wait>:

int
sys_wait(void)
{
80106818:	55                   	push   %ebp
80106819:	89 e5                	mov    %esp,%ebp
8010681b:	83 ec 08             	sub    $0x8,%esp
  return wait();
8010681e:	e8 63 e2 ff ff       	call   80104a86 <wait>
}
80106823:	c9                   	leave  
80106824:	c3                   	ret    

80106825 <sys_kill>:

int
sys_kill(void)
{
80106825:	55                   	push   %ebp
80106826:	89 e5                	mov    %esp,%ebp
80106828:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010682b:	83 ec 08             	sub    $0x8,%esp
8010682e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106831:	50                   	push   %eax
80106832:	6a 00                	push   $0x0
80106834:	e8 ed f0 ff ff       	call   80105926 <argint>
80106839:	83 c4 10             	add    $0x10,%esp
8010683c:	85 c0                	test   %eax,%eax
8010683e:	79 07                	jns    80106847 <sys_kill+0x22>
    return -1;
80106840:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106845:	eb 0f                	jmp    80106856 <sys_kill+0x31>
  return kill(pid);
80106847:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010684a:	83 ec 0c             	sub    $0xc,%esp
8010684d:	50                   	push   %eax
8010684e:	e8 c8 e6 ff ff       	call   80104f1b <kill>
80106853:	83 c4 10             	add    $0x10,%esp
}
80106856:	c9                   	leave  
80106857:	c3                   	ret    

80106858 <sys_getpid>:

int
sys_getpid(void)
{
80106858:	55                   	push   %ebp
80106859:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010685b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106861:	8b 40 10             	mov    0x10(%eax),%eax
}
80106864:	5d                   	pop    %ebp
80106865:	c3                   	ret    

80106866 <sys_sbrk>:

int
sys_sbrk(void)
{
80106866:	55                   	push   %ebp
80106867:	89 e5                	mov    %esp,%ebp
80106869:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010686c:	83 ec 08             	sub    $0x8,%esp
8010686f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106872:	50                   	push   %eax
80106873:	6a 00                	push   $0x0
80106875:	e8 ac f0 ff ff       	call   80105926 <argint>
8010687a:	83 c4 10             	add    $0x10,%esp
8010687d:	85 c0                	test   %eax,%eax
8010687f:	79 07                	jns    80106888 <sys_sbrk+0x22>
    return -1;
80106881:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106886:	eb 28                	jmp    801068b0 <sys_sbrk+0x4a>
  addr = proc->sz;
80106888:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010688e:	8b 00                	mov    (%eax),%eax
80106890:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106893:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106896:	83 ec 0c             	sub    $0xc,%esp
80106899:	50                   	push   %eax
8010689a:	e8 4e de ff ff       	call   801046ed <growproc>
8010689f:	83 c4 10             	add    $0x10,%esp
801068a2:	85 c0                	test   %eax,%eax
801068a4:	79 07                	jns    801068ad <sys_sbrk+0x47>
    return -1;
801068a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ab:	eb 03                	jmp    801068b0 <sys_sbrk+0x4a>
  return addr;
801068ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068b0:	c9                   	leave  
801068b1:	c3                   	ret    

801068b2 <sys_sleep>:

int
sys_sleep(void)
{
801068b2:	55                   	push   %ebp
801068b3:	89 e5                	mov    %esp,%ebp
801068b5:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801068b8:	83 ec 08             	sub    $0x8,%esp
801068bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068be:	50                   	push   %eax
801068bf:	6a 00                	push   $0x0
801068c1:	e8 60 f0 ff ff       	call   80105926 <argint>
801068c6:	83 c4 10             	add    $0x10,%esp
801068c9:	85 c0                	test   %eax,%eax
801068cb:	79 07                	jns    801068d4 <sys_sleep+0x22>
    return -1;
801068cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068d2:	eb 44                	jmp    80106918 <sys_sleep+0x66>
  ticks0 = ticks;
801068d4:	a1 c0 65 11 80       	mov    0x801165c0,%eax
801068d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801068dc:	eb 26                	jmp    80106904 <sys_sleep+0x52>
    if(proc->killed){
801068de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801068e4:	8b 40 24             	mov    0x24(%eax),%eax
801068e7:	85 c0                	test   %eax,%eax
801068e9:	74 07                	je     801068f2 <sys_sleep+0x40>
      return -1;
801068eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f0:	eb 26                	jmp    80106918 <sys_sleep+0x66>
    }
    sleep(&ticks, (struct spinlock *)0);
801068f2:	83 ec 08             	sub    $0x8,%esp
801068f5:	6a 00                	push   $0x0
801068f7:	68 c0 65 11 80       	push   $0x801165c0
801068fc:	e8 fc e4 ff ff       	call   80104dfd <sleep>
80106901:	83 c4 10             	add    $0x10,%esp
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106904:	a1 c0 65 11 80       	mov    0x801165c0,%eax
80106909:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010690c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010690f:	39 d0                	cmp    %edx,%eax
80106911:	72 cb                	jb     801068de <sys_sleep+0x2c>
    if(proc->killed){
      return -1;
    }
    sleep(&ticks, (struct spinlock *)0);
  }
  return 0;
80106913:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106918:	c9                   	leave  
80106919:	c3                   	ret    

8010691a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start. 
int
sys_uptime(void)
{
8010691a:	55                   	push   %ebp
8010691b:	89 e5                	mov    %esp,%ebp
8010691d:	83 ec 10             	sub    $0x10,%esp
  uint xticks;
  
  xticks = ticks;
80106920:	a1 c0 65 11 80       	mov    0x801165c0,%eax
80106925:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return xticks;
80106928:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010692b:	c9                   	leave  
8010692c:	c3                   	ret    

8010692d <sys_halt>:

//Turn of the computer
int
sys_halt(void){
8010692d:	55                   	push   %ebp
8010692e:	89 e5                	mov    %esp,%ebp
80106930:	83 ec 08             	sub    $0x8,%esp
  cprintf("Shutting down ...\n");
80106933:	83 ec 0c             	sub    $0xc,%esp
80106936:	68 32 8f 10 80       	push   $0x80108f32
8010693b:	e8 86 9a ff ff       	call   801003c6 <cprintf>
80106940:	83 c4 10             	add    $0x10,%esp
  outw( 0x604, 0x0 | 0x2000);
80106943:	83 ec 08             	sub    $0x8,%esp
80106946:	68 00 20 00 00       	push   $0x2000
8010694b:	68 04 06 00 00       	push   $0x604
80106950:	e8 83 fe ff ff       	call   801067d8 <outw>
80106955:	83 c4 10             	add    $0x10,%esp
  return 0;
80106958:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010695d:	c9                   	leave  
8010695e:	c3                   	ret    

8010695f <sys_date>:

#ifdef CS333_P1
int
sys_date(void)
{
8010695f:	55                   	push   %ebp
80106960:	89 e5                	mov    %esp,%ebp
80106962:	83 ec 18             	sub    $0x18,%esp
  struct rtcdate* d;

  if (argptr(0, (void*)&d, sizeof(struct rtcdate)) < 0)
80106965:	83 ec 04             	sub    $0x4,%esp
80106968:	6a 18                	push   $0x18
8010696a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010696d:	50                   	push   %eax
8010696e:	6a 00                	push   $0x0
80106970:	e8 d9 ef ff ff       	call   8010594e <argptr>
80106975:	83 c4 10             	add    $0x10,%esp
80106978:	85 c0                	test   %eax,%eax
8010697a:	79 07                	jns    80106983 <sys_date+0x24>
    return -1;
8010697c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106981:	eb 14                	jmp    80106997 <sys_date+0x38>

  cmostime(d);
80106983:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106986:	83 ec 0c             	sub    $0xc,%esp
80106989:	50                   	push   %eax
8010698a:	e8 39 c8 ff ff       	call   801031c8 <cmostime>
8010698f:	83 c4 10             	add    $0x10,%esp

  return 0;
80106992:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106997:	c9                   	leave  
80106998:	c3                   	ret    

80106999 <sys_getuid>:
#endif

#ifdef CS333_P2
int
sys_getuid(void)
{
80106999:	55                   	push   %ebp
8010699a:	89 e5                	mov    %esp,%ebp
  return proc->uid;
8010699c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069a2:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
801069a8:	5d                   	pop    %ebp
801069a9:	c3                   	ret    

801069aa <sys_getgid>:

int
sys_getgid(void)
{
801069aa:	55                   	push   %ebp
801069ab:	89 e5                	mov    %esp,%ebp
  return proc->gid;
801069ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069b3:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
}
801069b9:	5d                   	pop    %ebp
801069ba:	c3                   	ret    

801069bb <sys_getppid>:

int
sys_getppid(void)
{
801069bb:	55                   	push   %ebp
801069bc:	89 e5                	mov    %esp,%ebp
  return proc->parent->pid;
801069be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069c4:	8b 40 14             	mov    0x14(%eax),%eax
801069c7:	8b 40 10             	mov    0x10(%eax),%eax
}
801069ca:	5d                   	pop    %ebp
801069cb:	c3                   	ret    

801069cc <sys_setuid>:

int 
sys_setuid(void)
{
801069cc:	55                   	push   %ebp
801069cd:	89 e5                	mov    %esp,%ebp
801069cf:	83 ec 18             	sub    $0x18,%esp
  int x;

  if(argint(0, &x) < 0)
801069d2:	83 ec 08             	sub    $0x8,%esp
801069d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801069d8:	50                   	push   %eax
801069d9:	6a 00                	push   $0x0
801069db:	e8 46 ef ff ff       	call   80105926 <argint>
801069e0:	83 c4 10             	add    $0x10,%esp
801069e3:	85 c0                	test   %eax,%eax
801069e5:	79 07                	jns    801069ee <sys_setuid+0x22>
    return -1;
801069e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ec:	eb 2c                	jmp    80106a1a <sys_setuid+0x4e>

  if (x < 0 || x > 32767) return -1;
801069ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f1:	85 c0                	test   %eax,%eax
801069f3:	78 0a                	js     801069ff <sys_setuid+0x33>
801069f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f8:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
801069fd:	7e 07                	jle    80106a06 <sys_setuid+0x3a>
801069ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a04:	eb 14                	jmp    80106a1a <sys_setuid+0x4e>
  proc->uid = x;
80106a06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a0f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return 0;
80106a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a1a:	c9                   	leave  
80106a1b:	c3                   	ret    

80106a1c <sys_setgid>:

int
sys_setgid(void)
{
80106a1c:	55                   	push   %ebp
80106a1d:	89 e5                	mov    %esp,%ebp
80106a1f:	83 ec 18             	sub    $0x18,%esp
  int x;

  if(argint(0, &x) < 0)
80106a22:	83 ec 08             	sub    $0x8,%esp
80106a25:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a28:	50                   	push   %eax
80106a29:	6a 00                	push   $0x0
80106a2b:	e8 f6 ee ff ff       	call   80105926 <argint>
80106a30:	83 c4 10             	add    $0x10,%esp
80106a33:	85 c0                	test   %eax,%eax
80106a35:	79 07                	jns    80106a3e <sys_setgid+0x22>
    return -1;
80106a37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a3c:	eb 2c                	jmp    80106a6a <sys_setgid+0x4e>

  if (x < 0 || x > 32767) return -1;
80106a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a41:	85 c0                	test   %eax,%eax
80106a43:	78 0a                	js     80106a4f <sys_setgid+0x33>
80106a45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a48:	3d ff 7f 00 00       	cmp    $0x7fff,%eax
80106a4d:	7e 07                	jle    80106a56 <sys_setgid+0x3a>
80106a4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a54:	eb 14                	jmp    80106a6a <sys_setgid+0x4e>
  proc->gid = x;
80106a56:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a5f:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)

  return 0;
80106a65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a6a:	c9                   	leave  
80106a6b:	c3                   	ret    

80106a6c <sys_getprocs>:

int
sys_getprocs(void)
{
80106a6c:	55                   	push   %ebp
80106a6d:	89 e5                	mov    %esp,%ebp
80106a6f:	83 ec 18             	sub    $0x18,%esp
  int max;
  struct uproc* table;

  if(argint(0, &max) < 0)
80106a72:	83 ec 08             	sub    $0x8,%esp
80106a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a78:	50                   	push   %eax
80106a79:	6a 00                	push   $0x0
80106a7b:	e8 a6 ee ff ff       	call   80105926 <argint>
80106a80:	83 c4 10             	add    $0x10,%esp
80106a83:	85 c0                	test   %eax,%eax
80106a85:	79 07                	jns    80106a8e <sys_getprocs+0x22>
    return -1;
80106a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8c:	eb 31                	jmp    80106abf <sys_getprocs+0x53>
  
  if (argptr(1, (void*)&table, sizeof(struct uproc)) < 0)
80106a8e:	83 ec 04             	sub    $0x4,%esp
80106a91:	6a 5c                	push   $0x5c
80106a93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a96:	50                   	push   %eax
80106a97:	6a 01                	push   $0x1
80106a99:	e8 b0 ee ff ff       	call   8010594e <argptr>
80106a9e:	83 c4 10             	add    $0x10,%esp
80106aa1:	85 c0                	test   %eax,%eax
80106aa3:	79 07                	jns    80106aac <sys_getprocs+0x40>
    return -1;
80106aa5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aaa:	eb 13                	jmp    80106abf <sys_getprocs+0x53>

  return getprocs(max,table);
80106aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ab2:	83 ec 08             	sub    $0x8,%esp
80106ab5:	50                   	push   %eax
80106ab6:	52                   	push   %edx
80106ab7:	e8 6e e5 ff ff       	call   8010502a <getprocs>
80106abc:	83 c4 10             	add    $0x10,%esp
}
80106abf:	c9                   	leave  
80106ac0:	c3                   	ret    

80106ac1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106ac1:	55                   	push   %ebp
80106ac2:	89 e5                	mov    %esp,%ebp
80106ac4:	83 ec 08             	sub    $0x8,%esp
80106ac7:	8b 55 08             	mov    0x8(%ebp),%edx
80106aca:	8b 45 0c             	mov    0xc(%ebp),%eax
80106acd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106ad1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106ad4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106ad8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106adc:	ee                   	out    %al,(%dx)
}
80106add:	90                   	nop
80106ade:	c9                   	leave  
80106adf:	c3                   	ret    

80106ae0 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106ae0:	55                   	push   %ebp
80106ae1:	89 e5                	mov    %esp,%ebp
80106ae3:	83 ec 08             	sub    $0x8,%esp
  // Interrupt TPS times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106ae6:	6a 34                	push   $0x34
80106ae8:	6a 43                	push   $0x43
80106aea:	e8 d2 ff ff ff       	call   80106ac1 <outb>
80106aef:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) % 256);
80106af2:	68 a9 00 00 00       	push   $0xa9
80106af7:	6a 40                	push   $0x40
80106af9:	e8 c3 ff ff ff       	call   80106ac1 <outb>
80106afe:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(TPS) / 256);
80106b01:	6a 04                	push   $0x4
80106b03:	6a 40                	push   $0x40
80106b05:	e8 b7 ff ff ff       	call   80106ac1 <outb>
80106b0a:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106b0d:	83 ec 0c             	sub    $0xc,%esp
80106b10:	6a 00                	push   $0x0
80106b12:	e8 14 d4 ff ff       	call   80103f2b <picenable>
80106b17:	83 c4 10             	add    $0x10,%esp
}
80106b1a:	90                   	nop
80106b1b:	c9                   	leave  
80106b1c:	c3                   	ret    

80106b1d <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106b1d:	1e                   	push   %ds
  pushl %es
80106b1e:	06                   	push   %es
  pushl %fs
80106b1f:	0f a0                	push   %fs
  pushl %gs
80106b21:	0f a8                	push   %gs
  pushal
80106b23:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106b24:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106b28:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106b2a:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106b2c:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106b30:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106b32:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106b34:	54                   	push   %esp
  call trap
80106b35:	e8 ce 01 00 00       	call   80106d08 <trap>
  addl $4, %esp
80106b3a:	83 c4 04             	add    $0x4,%esp

80106b3d <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106b3d:	61                   	popa   
  popl %gs
80106b3e:	0f a9                	pop    %gs
  popl %fs
80106b40:	0f a1                	pop    %fs
  popl %es
80106b42:	07                   	pop    %es
  popl %ds
80106b43:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106b44:	83 c4 08             	add    $0x8,%esp
  iret
80106b47:	cf                   	iret   

80106b48 <atom_inc>:

// Routines added for CS333
// atom_inc() added to simplify handling of ticks global
static inline void
atom_inc(volatile int *num)
{
80106b48:	55                   	push   %ebp
80106b49:	89 e5                	mov    %esp,%ebp
  asm volatile ( "lock incl %0" : "=m" (*num));
80106b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4e:	f0 ff 00             	lock incl (%eax)
}
80106b51:	90                   	nop
80106b52:	5d                   	pop    %ebp
80106b53:	c3                   	ret    

80106b54 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106b54:	55                   	push   %ebp
80106b55:	89 e5                	mov    %esp,%ebp
80106b57:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b5d:	83 e8 01             	sub    $0x1,%eax
80106b60:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106b64:	8b 45 08             	mov    0x8(%ebp),%eax
80106b67:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80106b6e:	c1 e8 10             	shr    $0x10,%eax
80106b71:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106b75:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106b78:	0f 01 18             	lidtl  (%eax)
}
80106b7b:	90                   	nop
80106b7c:	c9                   	leave  
80106b7d:	c3                   	ret    

80106b7e <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106b7e:	55                   	push   %ebp
80106b7f:	89 e5                	mov    %esp,%ebp
80106b81:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106b84:	0f 20 d0             	mov    %cr2,%eax
80106b87:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106b8d:	c9                   	leave  
80106b8e:	c3                   	ret    

80106b8f <tvinit>:
// Software Developer’s Manual, Vol 3A, 8.1.1 Guaranteed Atomic Operations.
uint ticks __attribute__ ((aligned (4)));

void
tvinit(void)
{
80106b8f:	55                   	push   %ebp
80106b90:	89 e5                	mov    %esp,%ebp
80106b92:	83 ec 10             	sub    $0x10,%esp
  int i;

  for(i = 0; i < 256; i++)
80106b95:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80106b9c:	e9 c3 00 00 00       	jmp    80106c64 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106ba1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106ba4:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
80106bab:	89 c2                	mov    %eax,%edx
80106bad:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bb0:	66 89 14 c5 c0 5d 11 	mov    %dx,-0x7feea240(,%eax,8)
80106bb7:	80 
80106bb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bbb:	66 c7 04 c5 c2 5d 11 	movw   $0x8,-0x7feea23e(,%eax,8)
80106bc2:	80 08 00 
80106bc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bc8:	0f b6 14 c5 c4 5d 11 	movzbl -0x7feea23c(,%eax,8),%edx
80106bcf:	80 
80106bd0:	83 e2 e0             	and    $0xffffffe0,%edx
80106bd3:	88 14 c5 c4 5d 11 80 	mov    %dl,-0x7feea23c(,%eax,8)
80106bda:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bdd:	0f b6 14 c5 c4 5d 11 	movzbl -0x7feea23c(,%eax,8),%edx
80106be4:	80 
80106be5:	83 e2 1f             	and    $0x1f,%edx
80106be8:	88 14 c5 c4 5d 11 80 	mov    %dl,-0x7feea23c(,%eax,8)
80106bef:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106bf2:	0f b6 14 c5 c5 5d 11 	movzbl -0x7feea23b(,%eax,8),%edx
80106bf9:	80 
80106bfa:	83 e2 f0             	and    $0xfffffff0,%edx
80106bfd:	83 ca 0e             	or     $0xe,%edx
80106c00:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
80106c07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106c0a:	0f b6 14 c5 c5 5d 11 	movzbl -0x7feea23b(,%eax,8),%edx
80106c11:	80 
80106c12:	83 e2 ef             	and    $0xffffffef,%edx
80106c15:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
80106c1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106c1f:	0f b6 14 c5 c5 5d 11 	movzbl -0x7feea23b(,%eax,8),%edx
80106c26:	80 
80106c27:	83 e2 9f             	and    $0xffffff9f,%edx
80106c2a:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
80106c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106c34:	0f b6 14 c5 c5 5d 11 	movzbl -0x7feea23b(,%eax,8),%edx
80106c3b:	80 
80106c3c:	83 ca 80             	or     $0xffffff80,%edx
80106c3f:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
80106c46:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106c49:	8b 04 85 b8 c0 10 80 	mov    -0x7fef3f48(,%eax,4),%eax
80106c50:	c1 e8 10             	shr    $0x10,%eax
80106c53:	89 c2                	mov    %eax,%edx
80106c55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106c58:	66 89 14 c5 c6 5d 11 	mov    %dx,-0x7feea23a(,%eax,8)
80106c5f:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106c60:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106c64:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
80106c6b:	0f 8e 30 ff ff ff    	jle    80106ba1 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106c71:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
80106c76:	66 a3 c0 5f 11 80    	mov    %ax,0x80115fc0
80106c7c:	66 c7 05 c2 5f 11 80 	movw   $0x8,0x80115fc2
80106c83:	08 00 
80106c85:	0f b6 05 c4 5f 11 80 	movzbl 0x80115fc4,%eax
80106c8c:	83 e0 e0             	and    $0xffffffe0,%eax
80106c8f:	a2 c4 5f 11 80       	mov    %al,0x80115fc4
80106c94:	0f b6 05 c4 5f 11 80 	movzbl 0x80115fc4,%eax
80106c9b:	83 e0 1f             	and    $0x1f,%eax
80106c9e:	a2 c4 5f 11 80       	mov    %al,0x80115fc4
80106ca3:	0f b6 05 c5 5f 11 80 	movzbl 0x80115fc5,%eax
80106caa:	83 c8 0f             	or     $0xf,%eax
80106cad:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
80106cb2:	0f b6 05 c5 5f 11 80 	movzbl 0x80115fc5,%eax
80106cb9:	83 e0 ef             	and    $0xffffffef,%eax
80106cbc:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
80106cc1:	0f b6 05 c5 5f 11 80 	movzbl 0x80115fc5,%eax
80106cc8:	83 c8 60             	or     $0x60,%eax
80106ccb:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
80106cd0:	0f b6 05 c5 5f 11 80 	movzbl 0x80115fc5,%eax
80106cd7:	83 c8 80             	or     $0xffffff80,%eax
80106cda:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
80106cdf:	a1 b8 c1 10 80       	mov    0x8010c1b8,%eax
80106ce4:	c1 e8 10             	shr    $0x10,%eax
80106ce7:	66 a3 c6 5f 11 80    	mov    %ax,0x80115fc6
  
}
80106ced:	90                   	nop
80106cee:	c9                   	leave  
80106cef:	c3                   	ret    

80106cf0 <idtinit>:

void
idtinit(void)
{
80106cf0:	55                   	push   %ebp
80106cf1:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106cf3:	68 00 08 00 00       	push   $0x800
80106cf8:	68 c0 5d 11 80       	push   $0x80115dc0
80106cfd:	e8 52 fe ff ff       	call   80106b54 <lidt>
80106d02:	83 c4 08             	add    $0x8,%esp
}
80106d05:	90                   	nop
80106d06:	c9                   	leave  
80106d07:	c3                   	ret    

80106d08 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106d08:	55                   	push   %ebp
80106d09:	89 e5                	mov    %esp,%ebp
80106d0b:	57                   	push   %edi
80106d0c:	56                   	push   %esi
80106d0d:	53                   	push   %ebx
80106d0e:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106d11:	8b 45 08             	mov    0x8(%ebp),%eax
80106d14:	8b 40 30             	mov    0x30(%eax),%eax
80106d17:	83 f8 40             	cmp    $0x40,%eax
80106d1a:	75 3e                	jne    80106d5a <trap+0x52>
    if(proc->killed)
80106d1c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d22:	8b 40 24             	mov    0x24(%eax),%eax
80106d25:	85 c0                	test   %eax,%eax
80106d27:	74 05                	je     80106d2e <trap+0x26>
      exit();
80106d29:	e8 1d dc ff ff       	call   8010494b <exit>
    proc->tf = tf;
80106d2e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d34:	8b 55 08             	mov    0x8(%ebp),%edx
80106d37:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106d3a:	e8 9d ec ff ff       	call   801059dc <syscall>
    if(proc->killed)
80106d3f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106d45:	8b 40 24             	mov    0x24(%eax),%eax
80106d48:	85 c0                	test   %eax,%eax
80106d4a:	0f 84 21 02 00 00    	je     80106f71 <trap+0x269>
      exit();
80106d50:	e8 f6 db ff ff       	call   8010494b <exit>
    return;
80106d55:	e9 17 02 00 00       	jmp    80106f71 <trap+0x269>
  }

  switch(tf->trapno){
80106d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80106d5d:	8b 40 30             	mov    0x30(%eax),%eax
80106d60:	83 e8 20             	sub    $0x20,%eax
80106d63:	83 f8 1f             	cmp    $0x1f,%eax
80106d66:	0f 87 a3 00 00 00    	ja     80106e0f <trap+0x107>
80106d6c:	8b 04 85 e8 8f 10 80 	mov    -0x7fef7018(,%eax,4),%eax
80106d73:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
   if(cpu->id == 0){
80106d75:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106d7b:	0f b6 00             	movzbl (%eax),%eax
80106d7e:	84 c0                	test   %al,%al
80106d80:	75 20                	jne    80106da2 <trap+0x9a>
      atom_inc((int *)&ticks);   // guaranteed atomic so no lock necessary
80106d82:	83 ec 0c             	sub    $0xc,%esp
80106d85:	68 c0 65 11 80       	push   $0x801165c0
80106d8a:	e8 b9 fd ff ff       	call   80106b48 <atom_inc>
80106d8f:	83 c4 10             	add    $0x10,%esp
      wakeup(&ticks);
80106d92:	83 ec 0c             	sub    $0xc,%esp
80106d95:	68 c0 65 11 80       	push   $0x801165c0
80106d9a:	e8 45 e1 ff ff       	call   80104ee4 <wakeup>
80106d9f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106da2:	e8 7e c2 ff ff       	call   80103025 <lapiceoi>
    break;
80106da7:	e9 1c 01 00 00       	jmp    80106ec8 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106dac:	e8 87 ba ff ff       	call   80102838 <ideintr>
    lapiceoi();
80106db1:	e8 6f c2 ff ff       	call   80103025 <lapiceoi>
    break;
80106db6:	e9 0d 01 00 00       	jmp    80106ec8 <trap+0x1c0>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106dbb:	e8 67 c0 ff ff       	call   80102e27 <kbdintr>
    lapiceoi();
80106dc0:	e8 60 c2 ff ff       	call   80103025 <lapiceoi>
    break;
80106dc5:	e9 fe 00 00 00       	jmp    80106ec8 <trap+0x1c0>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106dca:	e8 83 03 00 00       	call   80107152 <uartintr>
    lapiceoi();
80106dcf:	e8 51 c2 ff ff       	call   80103025 <lapiceoi>
    break;
80106dd4:	e9 ef 00 00 00       	jmp    80106ec8 <trap+0x1c0>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80106ddc:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106ddf:	8b 45 08             	mov    0x8(%ebp),%eax
80106de2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106de6:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106de9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106def:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106df2:	0f b6 c0             	movzbl %al,%eax
80106df5:	51                   	push   %ecx
80106df6:	52                   	push   %edx
80106df7:	50                   	push   %eax
80106df8:	68 48 8f 10 80       	push   $0x80108f48
80106dfd:	e8 c4 95 ff ff       	call   801003c6 <cprintf>
80106e02:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106e05:	e8 1b c2 ff ff       	call   80103025 <lapiceoi>
    break;
80106e0a:	e9 b9 00 00 00       	jmp    80106ec8 <trap+0x1c0>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106e0f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e15:	85 c0                	test   %eax,%eax
80106e17:	74 11                	je     80106e2a <trap+0x122>
80106e19:	8b 45 08             	mov    0x8(%ebp),%eax
80106e1c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106e20:	0f b7 c0             	movzwl %ax,%eax
80106e23:	83 e0 03             	and    $0x3,%eax
80106e26:	85 c0                	test   %eax,%eax
80106e28:	75 40                	jne    80106e6a <trap+0x162>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e2a:	e8 4f fd ff ff       	call   80106b7e <rcr2>
80106e2f:	89 c3                	mov    %eax,%ebx
80106e31:	8b 45 08             	mov    0x8(%ebp),%eax
80106e34:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106e37:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e3d:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106e40:	0f b6 d0             	movzbl %al,%edx
80106e43:	8b 45 08             	mov    0x8(%ebp),%eax
80106e46:	8b 40 30             	mov    0x30(%eax),%eax
80106e49:	83 ec 0c             	sub    $0xc,%esp
80106e4c:	53                   	push   %ebx
80106e4d:	51                   	push   %ecx
80106e4e:	52                   	push   %edx
80106e4f:	50                   	push   %eax
80106e50:	68 6c 8f 10 80       	push   $0x80108f6c
80106e55:	e8 6c 95 ff ff       	call   801003c6 <cprintf>
80106e5a:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106e5d:	83 ec 0c             	sub    $0xc,%esp
80106e60:	68 9e 8f 10 80       	push   $0x80108f9e
80106e65:	e8 fc 96 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e6a:	e8 0f fd ff ff       	call   80106b7e <rcr2>
80106e6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e72:	8b 45 08             	mov    0x8(%ebp),%eax
80106e75:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e78:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106e7e:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e81:	0f b6 d8             	movzbl %al,%ebx
80106e84:	8b 45 08             	mov    0x8(%ebp),%eax
80106e87:	8b 48 34             	mov    0x34(%eax),%ecx
80106e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80106e8d:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106e90:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106e96:	8d 78 6c             	lea    0x6c(%eax),%edi
80106e99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106e9f:	8b 40 10             	mov    0x10(%eax),%eax
80106ea2:	ff 75 e4             	pushl  -0x1c(%ebp)
80106ea5:	56                   	push   %esi
80106ea6:	53                   	push   %ebx
80106ea7:	51                   	push   %ecx
80106ea8:	52                   	push   %edx
80106ea9:	57                   	push   %edi
80106eaa:	50                   	push   %eax
80106eab:	68 a4 8f 10 80       	push   $0x80108fa4
80106eb0:	e8 11 95 ff ff       	call   801003c6 <cprintf>
80106eb5:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106eb8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ebe:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106ec5:	eb 01                	jmp    80106ec8 <trap+0x1c0>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106ec7:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106ec8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ece:	85 c0                	test   %eax,%eax
80106ed0:	74 24                	je     80106ef6 <trap+0x1ee>
80106ed2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ed8:	8b 40 24             	mov    0x24(%eax),%eax
80106edb:	85 c0                	test   %eax,%eax
80106edd:	74 17                	je     80106ef6 <trap+0x1ee>
80106edf:	8b 45 08             	mov    0x8(%ebp),%eax
80106ee2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106ee6:	0f b7 c0             	movzwl %ax,%eax
80106ee9:	83 e0 03             	and    $0x3,%eax
80106eec:	83 f8 03             	cmp    $0x3,%eax
80106eef:	75 05                	jne    80106ef6 <trap+0x1ee>
    exit();
80106ef1:	e8 55 da ff ff       	call   8010494b <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80106ef6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106efc:	85 c0                	test   %eax,%eax
80106efe:	74 41                	je     80106f41 <trap+0x239>
80106f00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f06:	8b 40 0c             	mov    0xc(%eax),%eax
80106f09:	83 f8 04             	cmp    $0x4,%eax
80106f0c:	75 33                	jne    80106f41 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80106f0e:	8b 45 08             	mov    0x8(%ebp),%eax
80106f11:	8b 40 30             	mov    0x30(%eax),%eax
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING &&
80106f14:	83 f8 20             	cmp    $0x20,%eax
80106f17:	75 28                	jne    80106f41 <trap+0x239>
	  tf->trapno == T_IRQ0+IRQ_TIMER && ticks%SCHED_INTERVAL==0)
80106f19:	8b 0d c0 65 11 80    	mov    0x801165c0,%ecx
80106f1f:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80106f24:	89 c8                	mov    %ecx,%eax
80106f26:	f7 e2                	mul    %edx
80106f28:	c1 ea 03             	shr    $0x3,%edx
80106f2b:	89 d0                	mov    %edx,%eax
80106f2d:	c1 e0 02             	shl    $0x2,%eax
80106f30:	01 d0                	add    %edx,%eax
80106f32:	01 c0                	add    %eax,%eax
80106f34:	29 c1                	sub    %eax,%ecx
80106f36:	89 ca                	mov    %ecx,%edx
80106f38:	85 d2                	test   %edx,%edx
80106f3a:	75 05                	jne    80106f41 <trap+0x239>
    yield();
80106f3c:	e8 3b de ff ff       	call   80104d7c <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106f41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f47:	85 c0                	test   %eax,%eax
80106f49:	74 27                	je     80106f72 <trap+0x26a>
80106f4b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106f51:	8b 40 24             	mov    0x24(%eax),%eax
80106f54:	85 c0                	test   %eax,%eax
80106f56:	74 1a                	je     80106f72 <trap+0x26a>
80106f58:	8b 45 08             	mov    0x8(%ebp),%eax
80106f5b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106f5f:	0f b7 c0             	movzwl %ax,%eax
80106f62:	83 e0 03             	and    $0x3,%eax
80106f65:	83 f8 03             	cmp    $0x3,%eax
80106f68:	75 08                	jne    80106f72 <trap+0x26a>
    exit();
80106f6a:	e8 dc d9 ff ff       	call   8010494b <exit>
80106f6f:	eb 01                	jmp    80106f72 <trap+0x26a>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106f71:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106f72:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f75:	5b                   	pop    %ebx
80106f76:	5e                   	pop    %esi
80106f77:	5f                   	pop    %edi
80106f78:	5d                   	pop    %ebp
80106f79:	c3                   	ret    

80106f7a <inb>:

// end of CS333 added routines

static inline uchar
inb(ushort port)
{
80106f7a:	55                   	push   %ebp
80106f7b:	89 e5                	mov    %esp,%ebp
80106f7d:	83 ec 14             	sub    $0x14,%esp
80106f80:	8b 45 08             	mov    0x8(%ebp),%eax
80106f83:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106f87:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106f8b:	89 c2                	mov    %eax,%edx
80106f8d:	ec                   	in     (%dx),%al
80106f8e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106f91:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106f95:	c9                   	leave  
80106f96:	c3                   	ret    

80106f97 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106f97:	55                   	push   %ebp
80106f98:	89 e5                	mov    %esp,%ebp
80106f9a:	83 ec 08             	sub    $0x8,%esp
80106f9d:	8b 55 08             	mov    0x8(%ebp),%edx
80106fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fa3:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106fa7:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106faa:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106fae:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106fb2:	ee                   	out    %al,(%dx)
}
80106fb3:	90                   	nop
80106fb4:	c9                   	leave  
80106fb5:	c3                   	ret    

80106fb6 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106fb6:	55                   	push   %ebp
80106fb7:	89 e5                	mov    %esp,%ebp
80106fb9:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106fbc:	6a 00                	push   $0x0
80106fbe:	68 fa 03 00 00       	push   $0x3fa
80106fc3:	e8 cf ff ff ff       	call   80106f97 <outb>
80106fc8:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106fcb:	68 80 00 00 00       	push   $0x80
80106fd0:	68 fb 03 00 00       	push   $0x3fb
80106fd5:	e8 bd ff ff ff       	call   80106f97 <outb>
80106fda:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106fdd:	6a 0c                	push   $0xc
80106fdf:	68 f8 03 00 00       	push   $0x3f8
80106fe4:	e8 ae ff ff ff       	call   80106f97 <outb>
80106fe9:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106fec:	6a 00                	push   $0x0
80106fee:	68 f9 03 00 00       	push   $0x3f9
80106ff3:	e8 9f ff ff ff       	call   80106f97 <outb>
80106ff8:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106ffb:	6a 03                	push   $0x3
80106ffd:	68 fb 03 00 00       	push   $0x3fb
80107002:	e8 90 ff ff ff       	call   80106f97 <outb>
80107007:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
8010700a:	6a 00                	push   $0x0
8010700c:	68 fc 03 00 00       	push   $0x3fc
80107011:	e8 81 ff ff ff       	call   80106f97 <outb>
80107016:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107019:	6a 01                	push   $0x1
8010701b:	68 f9 03 00 00       	push   $0x3f9
80107020:	e8 72 ff ff ff       	call   80106f97 <outb>
80107025:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107028:	68 fd 03 00 00       	push   $0x3fd
8010702d:	e8 48 ff ff ff       	call   80106f7a <inb>
80107032:	83 c4 04             	add    $0x4,%esp
80107035:	3c ff                	cmp    $0xff,%al
80107037:	74 6e                	je     801070a7 <uartinit+0xf1>
    return;
  uart = 1;
80107039:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107040:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107043:	68 fa 03 00 00       	push   $0x3fa
80107048:	e8 2d ff ff ff       	call   80106f7a <inb>
8010704d:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107050:	68 f8 03 00 00       	push   $0x3f8
80107055:	e8 20 ff ff ff       	call   80106f7a <inb>
8010705a:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
8010705d:	83 ec 0c             	sub    $0xc,%esp
80107060:	6a 04                	push   $0x4
80107062:	e8 c4 ce ff ff       	call   80103f2b <picenable>
80107067:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
8010706a:	83 ec 08             	sub    $0x8,%esp
8010706d:	6a 00                	push   $0x0
8010706f:	6a 04                	push   $0x4
80107071:	e8 64 ba ff ff       	call   80102ada <ioapicenable>
80107076:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107079:	c7 45 f4 68 90 10 80 	movl   $0x80109068,-0xc(%ebp)
80107080:	eb 19                	jmp    8010709b <uartinit+0xe5>
    uartputc(*p);
80107082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107085:	0f b6 00             	movzbl (%eax),%eax
80107088:	0f be c0             	movsbl %al,%eax
8010708b:	83 ec 0c             	sub    $0xc,%esp
8010708e:	50                   	push   %eax
8010708f:	e8 16 00 00 00       	call   801070aa <uartputc>
80107094:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107097:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010709b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709e:	0f b6 00             	movzbl (%eax),%eax
801070a1:	84 c0                	test   %al,%al
801070a3:	75 dd                	jne    80107082 <uartinit+0xcc>
801070a5:	eb 01                	jmp    801070a8 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801070a7:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801070a8:	c9                   	leave  
801070a9:	c3                   	ret    

801070aa <uartputc>:

void
uartputc(int c)
{
801070aa:	55                   	push   %ebp
801070ab:	89 e5                	mov    %esp,%ebp
801070ad:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801070b0:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801070b5:	85 c0                	test   %eax,%eax
801070b7:	74 53                	je     8010710c <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070c0:	eb 11                	jmp    801070d3 <uartputc+0x29>
    microdelay(10);
801070c2:	83 ec 0c             	sub    $0xc,%esp
801070c5:	6a 0a                	push   $0xa
801070c7:	e8 74 bf ff ff       	call   80103040 <microdelay>
801070cc:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801070cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801070d3:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801070d7:	7f 1a                	jg     801070f3 <uartputc+0x49>
801070d9:	83 ec 0c             	sub    $0xc,%esp
801070dc:	68 fd 03 00 00       	push   $0x3fd
801070e1:	e8 94 fe ff ff       	call   80106f7a <inb>
801070e6:	83 c4 10             	add    $0x10,%esp
801070e9:	0f b6 c0             	movzbl %al,%eax
801070ec:	83 e0 20             	and    $0x20,%eax
801070ef:	85 c0                	test   %eax,%eax
801070f1:	74 cf                	je     801070c2 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
801070f3:	8b 45 08             	mov    0x8(%ebp),%eax
801070f6:	0f b6 c0             	movzbl %al,%eax
801070f9:	83 ec 08             	sub    $0x8,%esp
801070fc:	50                   	push   %eax
801070fd:	68 f8 03 00 00       	push   $0x3f8
80107102:	e8 90 fe ff ff       	call   80106f97 <outb>
80107107:	83 c4 10             	add    $0x10,%esp
8010710a:	eb 01                	jmp    8010710d <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
8010710c:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
8010710d:	c9                   	leave  
8010710e:	c3                   	ret    

8010710f <uartgetc>:

static int
uartgetc(void)
{
8010710f:	55                   	push   %ebp
80107110:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107112:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
80107117:	85 c0                	test   %eax,%eax
80107119:	75 07                	jne    80107122 <uartgetc+0x13>
    return -1;
8010711b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107120:	eb 2e                	jmp    80107150 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80107122:	68 fd 03 00 00       	push   $0x3fd
80107127:	e8 4e fe ff ff       	call   80106f7a <inb>
8010712c:	83 c4 04             	add    $0x4,%esp
8010712f:	0f b6 c0             	movzbl %al,%eax
80107132:	83 e0 01             	and    $0x1,%eax
80107135:	85 c0                	test   %eax,%eax
80107137:	75 07                	jne    80107140 <uartgetc+0x31>
    return -1;
80107139:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010713e:	eb 10                	jmp    80107150 <uartgetc+0x41>
  return inb(COM1+0);
80107140:	68 f8 03 00 00       	push   $0x3f8
80107145:	e8 30 fe ff ff       	call   80106f7a <inb>
8010714a:	83 c4 04             	add    $0x4,%esp
8010714d:	0f b6 c0             	movzbl %al,%eax
}
80107150:	c9                   	leave  
80107151:	c3                   	ret    

80107152 <uartintr>:

void
uartintr(void)
{
80107152:	55                   	push   %ebp
80107153:	89 e5                	mov    %esp,%ebp
80107155:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107158:	83 ec 0c             	sub    $0xc,%esp
8010715b:	68 0f 71 10 80       	push   $0x8010710f
80107160:	e8 94 96 ff ff       	call   801007f9 <consoleintr>
80107165:	83 c4 10             	add    $0x10,%esp
}
80107168:	90                   	nop
80107169:	c9                   	leave  
8010716a:	c3                   	ret    

8010716b <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010716b:	6a 00                	push   $0x0
  pushl $0
8010716d:	6a 00                	push   $0x0
  jmp alltraps
8010716f:	e9 a9 f9 ff ff       	jmp    80106b1d <alltraps>

80107174 <vector1>:
.globl vector1
vector1:
  pushl $0
80107174:	6a 00                	push   $0x0
  pushl $1
80107176:	6a 01                	push   $0x1
  jmp alltraps
80107178:	e9 a0 f9 ff ff       	jmp    80106b1d <alltraps>

8010717d <vector2>:
.globl vector2
vector2:
  pushl $0
8010717d:	6a 00                	push   $0x0
  pushl $2
8010717f:	6a 02                	push   $0x2
  jmp alltraps
80107181:	e9 97 f9 ff ff       	jmp    80106b1d <alltraps>

80107186 <vector3>:
.globl vector3
vector3:
  pushl $0
80107186:	6a 00                	push   $0x0
  pushl $3
80107188:	6a 03                	push   $0x3
  jmp alltraps
8010718a:	e9 8e f9 ff ff       	jmp    80106b1d <alltraps>

8010718f <vector4>:
.globl vector4
vector4:
  pushl $0
8010718f:	6a 00                	push   $0x0
  pushl $4
80107191:	6a 04                	push   $0x4
  jmp alltraps
80107193:	e9 85 f9 ff ff       	jmp    80106b1d <alltraps>

80107198 <vector5>:
.globl vector5
vector5:
  pushl $0
80107198:	6a 00                	push   $0x0
  pushl $5
8010719a:	6a 05                	push   $0x5
  jmp alltraps
8010719c:	e9 7c f9 ff ff       	jmp    80106b1d <alltraps>

801071a1 <vector6>:
.globl vector6
vector6:
  pushl $0
801071a1:	6a 00                	push   $0x0
  pushl $6
801071a3:	6a 06                	push   $0x6
  jmp alltraps
801071a5:	e9 73 f9 ff ff       	jmp    80106b1d <alltraps>

801071aa <vector7>:
.globl vector7
vector7:
  pushl $0
801071aa:	6a 00                	push   $0x0
  pushl $7
801071ac:	6a 07                	push   $0x7
  jmp alltraps
801071ae:	e9 6a f9 ff ff       	jmp    80106b1d <alltraps>

801071b3 <vector8>:
.globl vector8
vector8:
  pushl $8
801071b3:	6a 08                	push   $0x8
  jmp alltraps
801071b5:	e9 63 f9 ff ff       	jmp    80106b1d <alltraps>

801071ba <vector9>:
.globl vector9
vector9:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $9
801071bc:	6a 09                	push   $0x9
  jmp alltraps
801071be:	e9 5a f9 ff ff       	jmp    80106b1d <alltraps>

801071c3 <vector10>:
.globl vector10
vector10:
  pushl $10
801071c3:	6a 0a                	push   $0xa
  jmp alltraps
801071c5:	e9 53 f9 ff ff       	jmp    80106b1d <alltraps>

801071ca <vector11>:
.globl vector11
vector11:
  pushl $11
801071ca:	6a 0b                	push   $0xb
  jmp alltraps
801071cc:	e9 4c f9 ff ff       	jmp    80106b1d <alltraps>

801071d1 <vector12>:
.globl vector12
vector12:
  pushl $12
801071d1:	6a 0c                	push   $0xc
  jmp alltraps
801071d3:	e9 45 f9 ff ff       	jmp    80106b1d <alltraps>

801071d8 <vector13>:
.globl vector13
vector13:
  pushl $13
801071d8:	6a 0d                	push   $0xd
  jmp alltraps
801071da:	e9 3e f9 ff ff       	jmp    80106b1d <alltraps>

801071df <vector14>:
.globl vector14
vector14:
  pushl $14
801071df:	6a 0e                	push   $0xe
  jmp alltraps
801071e1:	e9 37 f9 ff ff       	jmp    80106b1d <alltraps>

801071e6 <vector15>:
.globl vector15
vector15:
  pushl $0
801071e6:	6a 00                	push   $0x0
  pushl $15
801071e8:	6a 0f                	push   $0xf
  jmp alltraps
801071ea:	e9 2e f9 ff ff       	jmp    80106b1d <alltraps>

801071ef <vector16>:
.globl vector16
vector16:
  pushl $0
801071ef:	6a 00                	push   $0x0
  pushl $16
801071f1:	6a 10                	push   $0x10
  jmp alltraps
801071f3:	e9 25 f9 ff ff       	jmp    80106b1d <alltraps>

801071f8 <vector17>:
.globl vector17
vector17:
  pushl $17
801071f8:	6a 11                	push   $0x11
  jmp alltraps
801071fa:	e9 1e f9 ff ff       	jmp    80106b1d <alltraps>

801071ff <vector18>:
.globl vector18
vector18:
  pushl $0
801071ff:	6a 00                	push   $0x0
  pushl $18
80107201:	6a 12                	push   $0x12
  jmp alltraps
80107203:	e9 15 f9 ff ff       	jmp    80106b1d <alltraps>

80107208 <vector19>:
.globl vector19
vector19:
  pushl $0
80107208:	6a 00                	push   $0x0
  pushl $19
8010720a:	6a 13                	push   $0x13
  jmp alltraps
8010720c:	e9 0c f9 ff ff       	jmp    80106b1d <alltraps>

80107211 <vector20>:
.globl vector20
vector20:
  pushl $0
80107211:	6a 00                	push   $0x0
  pushl $20
80107213:	6a 14                	push   $0x14
  jmp alltraps
80107215:	e9 03 f9 ff ff       	jmp    80106b1d <alltraps>

8010721a <vector21>:
.globl vector21
vector21:
  pushl $0
8010721a:	6a 00                	push   $0x0
  pushl $21
8010721c:	6a 15                	push   $0x15
  jmp alltraps
8010721e:	e9 fa f8 ff ff       	jmp    80106b1d <alltraps>

80107223 <vector22>:
.globl vector22
vector22:
  pushl $0
80107223:	6a 00                	push   $0x0
  pushl $22
80107225:	6a 16                	push   $0x16
  jmp alltraps
80107227:	e9 f1 f8 ff ff       	jmp    80106b1d <alltraps>

8010722c <vector23>:
.globl vector23
vector23:
  pushl $0
8010722c:	6a 00                	push   $0x0
  pushl $23
8010722e:	6a 17                	push   $0x17
  jmp alltraps
80107230:	e9 e8 f8 ff ff       	jmp    80106b1d <alltraps>

80107235 <vector24>:
.globl vector24
vector24:
  pushl $0
80107235:	6a 00                	push   $0x0
  pushl $24
80107237:	6a 18                	push   $0x18
  jmp alltraps
80107239:	e9 df f8 ff ff       	jmp    80106b1d <alltraps>

8010723e <vector25>:
.globl vector25
vector25:
  pushl $0
8010723e:	6a 00                	push   $0x0
  pushl $25
80107240:	6a 19                	push   $0x19
  jmp alltraps
80107242:	e9 d6 f8 ff ff       	jmp    80106b1d <alltraps>

80107247 <vector26>:
.globl vector26
vector26:
  pushl $0
80107247:	6a 00                	push   $0x0
  pushl $26
80107249:	6a 1a                	push   $0x1a
  jmp alltraps
8010724b:	e9 cd f8 ff ff       	jmp    80106b1d <alltraps>

80107250 <vector27>:
.globl vector27
vector27:
  pushl $0
80107250:	6a 00                	push   $0x0
  pushl $27
80107252:	6a 1b                	push   $0x1b
  jmp alltraps
80107254:	e9 c4 f8 ff ff       	jmp    80106b1d <alltraps>

80107259 <vector28>:
.globl vector28
vector28:
  pushl $0
80107259:	6a 00                	push   $0x0
  pushl $28
8010725b:	6a 1c                	push   $0x1c
  jmp alltraps
8010725d:	e9 bb f8 ff ff       	jmp    80106b1d <alltraps>

80107262 <vector29>:
.globl vector29
vector29:
  pushl $0
80107262:	6a 00                	push   $0x0
  pushl $29
80107264:	6a 1d                	push   $0x1d
  jmp alltraps
80107266:	e9 b2 f8 ff ff       	jmp    80106b1d <alltraps>

8010726b <vector30>:
.globl vector30
vector30:
  pushl $0
8010726b:	6a 00                	push   $0x0
  pushl $30
8010726d:	6a 1e                	push   $0x1e
  jmp alltraps
8010726f:	e9 a9 f8 ff ff       	jmp    80106b1d <alltraps>

80107274 <vector31>:
.globl vector31
vector31:
  pushl $0
80107274:	6a 00                	push   $0x0
  pushl $31
80107276:	6a 1f                	push   $0x1f
  jmp alltraps
80107278:	e9 a0 f8 ff ff       	jmp    80106b1d <alltraps>

8010727d <vector32>:
.globl vector32
vector32:
  pushl $0
8010727d:	6a 00                	push   $0x0
  pushl $32
8010727f:	6a 20                	push   $0x20
  jmp alltraps
80107281:	e9 97 f8 ff ff       	jmp    80106b1d <alltraps>

80107286 <vector33>:
.globl vector33
vector33:
  pushl $0
80107286:	6a 00                	push   $0x0
  pushl $33
80107288:	6a 21                	push   $0x21
  jmp alltraps
8010728a:	e9 8e f8 ff ff       	jmp    80106b1d <alltraps>

8010728f <vector34>:
.globl vector34
vector34:
  pushl $0
8010728f:	6a 00                	push   $0x0
  pushl $34
80107291:	6a 22                	push   $0x22
  jmp alltraps
80107293:	e9 85 f8 ff ff       	jmp    80106b1d <alltraps>

80107298 <vector35>:
.globl vector35
vector35:
  pushl $0
80107298:	6a 00                	push   $0x0
  pushl $35
8010729a:	6a 23                	push   $0x23
  jmp alltraps
8010729c:	e9 7c f8 ff ff       	jmp    80106b1d <alltraps>

801072a1 <vector36>:
.globl vector36
vector36:
  pushl $0
801072a1:	6a 00                	push   $0x0
  pushl $36
801072a3:	6a 24                	push   $0x24
  jmp alltraps
801072a5:	e9 73 f8 ff ff       	jmp    80106b1d <alltraps>

801072aa <vector37>:
.globl vector37
vector37:
  pushl $0
801072aa:	6a 00                	push   $0x0
  pushl $37
801072ac:	6a 25                	push   $0x25
  jmp alltraps
801072ae:	e9 6a f8 ff ff       	jmp    80106b1d <alltraps>

801072b3 <vector38>:
.globl vector38
vector38:
  pushl $0
801072b3:	6a 00                	push   $0x0
  pushl $38
801072b5:	6a 26                	push   $0x26
  jmp alltraps
801072b7:	e9 61 f8 ff ff       	jmp    80106b1d <alltraps>

801072bc <vector39>:
.globl vector39
vector39:
  pushl $0
801072bc:	6a 00                	push   $0x0
  pushl $39
801072be:	6a 27                	push   $0x27
  jmp alltraps
801072c0:	e9 58 f8 ff ff       	jmp    80106b1d <alltraps>

801072c5 <vector40>:
.globl vector40
vector40:
  pushl $0
801072c5:	6a 00                	push   $0x0
  pushl $40
801072c7:	6a 28                	push   $0x28
  jmp alltraps
801072c9:	e9 4f f8 ff ff       	jmp    80106b1d <alltraps>

801072ce <vector41>:
.globl vector41
vector41:
  pushl $0
801072ce:	6a 00                	push   $0x0
  pushl $41
801072d0:	6a 29                	push   $0x29
  jmp alltraps
801072d2:	e9 46 f8 ff ff       	jmp    80106b1d <alltraps>

801072d7 <vector42>:
.globl vector42
vector42:
  pushl $0
801072d7:	6a 00                	push   $0x0
  pushl $42
801072d9:	6a 2a                	push   $0x2a
  jmp alltraps
801072db:	e9 3d f8 ff ff       	jmp    80106b1d <alltraps>

801072e0 <vector43>:
.globl vector43
vector43:
  pushl $0
801072e0:	6a 00                	push   $0x0
  pushl $43
801072e2:	6a 2b                	push   $0x2b
  jmp alltraps
801072e4:	e9 34 f8 ff ff       	jmp    80106b1d <alltraps>

801072e9 <vector44>:
.globl vector44
vector44:
  pushl $0
801072e9:	6a 00                	push   $0x0
  pushl $44
801072eb:	6a 2c                	push   $0x2c
  jmp alltraps
801072ed:	e9 2b f8 ff ff       	jmp    80106b1d <alltraps>

801072f2 <vector45>:
.globl vector45
vector45:
  pushl $0
801072f2:	6a 00                	push   $0x0
  pushl $45
801072f4:	6a 2d                	push   $0x2d
  jmp alltraps
801072f6:	e9 22 f8 ff ff       	jmp    80106b1d <alltraps>

801072fb <vector46>:
.globl vector46
vector46:
  pushl $0
801072fb:	6a 00                	push   $0x0
  pushl $46
801072fd:	6a 2e                	push   $0x2e
  jmp alltraps
801072ff:	e9 19 f8 ff ff       	jmp    80106b1d <alltraps>

80107304 <vector47>:
.globl vector47
vector47:
  pushl $0
80107304:	6a 00                	push   $0x0
  pushl $47
80107306:	6a 2f                	push   $0x2f
  jmp alltraps
80107308:	e9 10 f8 ff ff       	jmp    80106b1d <alltraps>

8010730d <vector48>:
.globl vector48
vector48:
  pushl $0
8010730d:	6a 00                	push   $0x0
  pushl $48
8010730f:	6a 30                	push   $0x30
  jmp alltraps
80107311:	e9 07 f8 ff ff       	jmp    80106b1d <alltraps>

80107316 <vector49>:
.globl vector49
vector49:
  pushl $0
80107316:	6a 00                	push   $0x0
  pushl $49
80107318:	6a 31                	push   $0x31
  jmp alltraps
8010731a:	e9 fe f7 ff ff       	jmp    80106b1d <alltraps>

8010731f <vector50>:
.globl vector50
vector50:
  pushl $0
8010731f:	6a 00                	push   $0x0
  pushl $50
80107321:	6a 32                	push   $0x32
  jmp alltraps
80107323:	e9 f5 f7 ff ff       	jmp    80106b1d <alltraps>

80107328 <vector51>:
.globl vector51
vector51:
  pushl $0
80107328:	6a 00                	push   $0x0
  pushl $51
8010732a:	6a 33                	push   $0x33
  jmp alltraps
8010732c:	e9 ec f7 ff ff       	jmp    80106b1d <alltraps>

80107331 <vector52>:
.globl vector52
vector52:
  pushl $0
80107331:	6a 00                	push   $0x0
  pushl $52
80107333:	6a 34                	push   $0x34
  jmp alltraps
80107335:	e9 e3 f7 ff ff       	jmp    80106b1d <alltraps>

8010733a <vector53>:
.globl vector53
vector53:
  pushl $0
8010733a:	6a 00                	push   $0x0
  pushl $53
8010733c:	6a 35                	push   $0x35
  jmp alltraps
8010733e:	e9 da f7 ff ff       	jmp    80106b1d <alltraps>

80107343 <vector54>:
.globl vector54
vector54:
  pushl $0
80107343:	6a 00                	push   $0x0
  pushl $54
80107345:	6a 36                	push   $0x36
  jmp alltraps
80107347:	e9 d1 f7 ff ff       	jmp    80106b1d <alltraps>

8010734c <vector55>:
.globl vector55
vector55:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $55
8010734e:	6a 37                	push   $0x37
  jmp alltraps
80107350:	e9 c8 f7 ff ff       	jmp    80106b1d <alltraps>

80107355 <vector56>:
.globl vector56
vector56:
  pushl $0
80107355:	6a 00                	push   $0x0
  pushl $56
80107357:	6a 38                	push   $0x38
  jmp alltraps
80107359:	e9 bf f7 ff ff       	jmp    80106b1d <alltraps>

8010735e <vector57>:
.globl vector57
vector57:
  pushl $0
8010735e:	6a 00                	push   $0x0
  pushl $57
80107360:	6a 39                	push   $0x39
  jmp alltraps
80107362:	e9 b6 f7 ff ff       	jmp    80106b1d <alltraps>

80107367 <vector58>:
.globl vector58
vector58:
  pushl $0
80107367:	6a 00                	push   $0x0
  pushl $58
80107369:	6a 3a                	push   $0x3a
  jmp alltraps
8010736b:	e9 ad f7 ff ff       	jmp    80106b1d <alltraps>

80107370 <vector59>:
.globl vector59
vector59:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $59
80107372:	6a 3b                	push   $0x3b
  jmp alltraps
80107374:	e9 a4 f7 ff ff       	jmp    80106b1d <alltraps>

80107379 <vector60>:
.globl vector60
vector60:
  pushl $0
80107379:	6a 00                	push   $0x0
  pushl $60
8010737b:	6a 3c                	push   $0x3c
  jmp alltraps
8010737d:	e9 9b f7 ff ff       	jmp    80106b1d <alltraps>

80107382 <vector61>:
.globl vector61
vector61:
  pushl $0
80107382:	6a 00                	push   $0x0
  pushl $61
80107384:	6a 3d                	push   $0x3d
  jmp alltraps
80107386:	e9 92 f7 ff ff       	jmp    80106b1d <alltraps>

8010738b <vector62>:
.globl vector62
vector62:
  pushl $0
8010738b:	6a 00                	push   $0x0
  pushl $62
8010738d:	6a 3e                	push   $0x3e
  jmp alltraps
8010738f:	e9 89 f7 ff ff       	jmp    80106b1d <alltraps>

80107394 <vector63>:
.globl vector63
vector63:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $63
80107396:	6a 3f                	push   $0x3f
  jmp alltraps
80107398:	e9 80 f7 ff ff       	jmp    80106b1d <alltraps>

8010739d <vector64>:
.globl vector64
vector64:
  pushl $0
8010739d:	6a 00                	push   $0x0
  pushl $64
8010739f:	6a 40                	push   $0x40
  jmp alltraps
801073a1:	e9 77 f7 ff ff       	jmp    80106b1d <alltraps>

801073a6 <vector65>:
.globl vector65
vector65:
  pushl $0
801073a6:	6a 00                	push   $0x0
  pushl $65
801073a8:	6a 41                	push   $0x41
  jmp alltraps
801073aa:	e9 6e f7 ff ff       	jmp    80106b1d <alltraps>

801073af <vector66>:
.globl vector66
vector66:
  pushl $0
801073af:	6a 00                	push   $0x0
  pushl $66
801073b1:	6a 42                	push   $0x42
  jmp alltraps
801073b3:	e9 65 f7 ff ff       	jmp    80106b1d <alltraps>

801073b8 <vector67>:
.globl vector67
vector67:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $67
801073ba:	6a 43                	push   $0x43
  jmp alltraps
801073bc:	e9 5c f7 ff ff       	jmp    80106b1d <alltraps>

801073c1 <vector68>:
.globl vector68
vector68:
  pushl $0
801073c1:	6a 00                	push   $0x0
  pushl $68
801073c3:	6a 44                	push   $0x44
  jmp alltraps
801073c5:	e9 53 f7 ff ff       	jmp    80106b1d <alltraps>

801073ca <vector69>:
.globl vector69
vector69:
  pushl $0
801073ca:	6a 00                	push   $0x0
  pushl $69
801073cc:	6a 45                	push   $0x45
  jmp alltraps
801073ce:	e9 4a f7 ff ff       	jmp    80106b1d <alltraps>

801073d3 <vector70>:
.globl vector70
vector70:
  pushl $0
801073d3:	6a 00                	push   $0x0
  pushl $70
801073d5:	6a 46                	push   $0x46
  jmp alltraps
801073d7:	e9 41 f7 ff ff       	jmp    80106b1d <alltraps>

801073dc <vector71>:
.globl vector71
vector71:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $71
801073de:	6a 47                	push   $0x47
  jmp alltraps
801073e0:	e9 38 f7 ff ff       	jmp    80106b1d <alltraps>

801073e5 <vector72>:
.globl vector72
vector72:
  pushl $0
801073e5:	6a 00                	push   $0x0
  pushl $72
801073e7:	6a 48                	push   $0x48
  jmp alltraps
801073e9:	e9 2f f7 ff ff       	jmp    80106b1d <alltraps>

801073ee <vector73>:
.globl vector73
vector73:
  pushl $0
801073ee:	6a 00                	push   $0x0
  pushl $73
801073f0:	6a 49                	push   $0x49
  jmp alltraps
801073f2:	e9 26 f7 ff ff       	jmp    80106b1d <alltraps>

801073f7 <vector74>:
.globl vector74
vector74:
  pushl $0
801073f7:	6a 00                	push   $0x0
  pushl $74
801073f9:	6a 4a                	push   $0x4a
  jmp alltraps
801073fb:	e9 1d f7 ff ff       	jmp    80106b1d <alltraps>

80107400 <vector75>:
.globl vector75
vector75:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $75
80107402:	6a 4b                	push   $0x4b
  jmp alltraps
80107404:	e9 14 f7 ff ff       	jmp    80106b1d <alltraps>

80107409 <vector76>:
.globl vector76
vector76:
  pushl $0
80107409:	6a 00                	push   $0x0
  pushl $76
8010740b:	6a 4c                	push   $0x4c
  jmp alltraps
8010740d:	e9 0b f7 ff ff       	jmp    80106b1d <alltraps>

80107412 <vector77>:
.globl vector77
vector77:
  pushl $0
80107412:	6a 00                	push   $0x0
  pushl $77
80107414:	6a 4d                	push   $0x4d
  jmp alltraps
80107416:	e9 02 f7 ff ff       	jmp    80106b1d <alltraps>

8010741b <vector78>:
.globl vector78
vector78:
  pushl $0
8010741b:	6a 00                	push   $0x0
  pushl $78
8010741d:	6a 4e                	push   $0x4e
  jmp alltraps
8010741f:	e9 f9 f6 ff ff       	jmp    80106b1d <alltraps>

80107424 <vector79>:
.globl vector79
vector79:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $79
80107426:	6a 4f                	push   $0x4f
  jmp alltraps
80107428:	e9 f0 f6 ff ff       	jmp    80106b1d <alltraps>

8010742d <vector80>:
.globl vector80
vector80:
  pushl $0
8010742d:	6a 00                	push   $0x0
  pushl $80
8010742f:	6a 50                	push   $0x50
  jmp alltraps
80107431:	e9 e7 f6 ff ff       	jmp    80106b1d <alltraps>

80107436 <vector81>:
.globl vector81
vector81:
  pushl $0
80107436:	6a 00                	push   $0x0
  pushl $81
80107438:	6a 51                	push   $0x51
  jmp alltraps
8010743a:	e9 de f6 ff ff       	jmp    80106b1d <alltraps>

8010743f <vector82>:
.globl vector82
vector82:
  pushl $0
8010743f:	6a 00                	push   $0x0
  pushl $82
80107441:	6a 52                	push   $0x52
  jmp alltraps
80107443:	e9 d5 f6 ff ff       	jmp    80106b1d <alltraps>

80107448 <vector83>:
.globl vector83
vector83:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $83
8010744a:	6a 53                	push   $0x53
  jmp alltraps
8010744c:	e9 cc f6 ff ff       	jmp    80106b1d <alltraps>

80107451 <vector84>:
.globl vector84
vector84:
  pushl $0
80107451:	6a 00                	push   $0x0
  pushl $84
80107453:	6a 54                	push   $0x54
  jmp alltraps
80107455:	e9 c3 f6 ff ff       	jmp    80106b1d <alltraps>

8010745a <vector85>:
.globl vector85
vector85:
  pushl $0
8010745a:	6a 00                	push   $0x0
  pushl $85
8010745c:	6a 55                	push   $0x55
  jmp alltraps
8010745e:	e9 ba f6 ff ff       	jmp    80106b1d <alltraps>

80107463 <vector86>:
.globl vector86
vector86:
  pushl $0
80107463:	6a 00                	push   $0x0
  pushl $86
80107465:	6a 56                	push   $0x56
  jmp alltraps
80107467:	e9 b1 f6 ff ff       	jmp    80106b1d <alltraps>

8010746c <vector87>:
.globl vector87
vector87:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $87
8010746e:	6a 57                	push   $0x57
  jmp alltraps
80107470:	e9 a8 f6 ff ff       	jmp    80106b1d <alltraps>

80107475 <vector88>:
.globl vector88
vector88:
  pushl $0
80107475:	6a 00                	push   $0x0
  pushl $88
80107477:	6a 58                	push   $0x58
  jmp alltraps
80107479:	e9 9f f6 ff ff       	jmp    80106b1d <alltraps>

8010747e <vector89>:
.globl vector89
vector89:
  pushl $0
8010747e:	6a 00                	push   $0x0
  pushl $89
80107480:	6a 59                	push   $0x59
  jmp alltraps
80107482:	e9 96 f6 ff ff       	jmp    80106b1d <alltraps>

80107487 <vector90>:
.globl vector90
vector90:
  pushl $0
80107487:	6a 00                	push   $0x0
  pushl $90
80107489:	6a 5a                	push   $0x5a
  jmp alltraps
8010748b:	e9 8d f6 ff ff       	jmp    80106b1d <alltraps>

80107490 <vector91>:
.globl vector91
vector91:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $91
80107492:	6a 5b                	push   $0x5b
  jmp alltraps
80107494:	e9 84 f6 ff ff       	jmp    80106b1d <alltraps>

80107499 <vector92>:
.globl vector92
vector92:
  pushl $0
80107499:	6a 00                	push   $0x0
  pushl $92
8010749b:	6a 5c                	push   $0x5c
  jmp alltraps
8010749d:	e9 7b f6 ff ff       	jmp    80106b1d <alltraps>

801074a2 <vector93>:
.globl vector93
vector93:
  pushl $0
801074a2:	6a 00                	push   $0x0
  pushl $93
801074a4:	6a 5d                	push   $0x5d
  jmp alltraps
801074a6:	e9 72 f6 ff ff       	jmp    80106b1d <alltraps>

801074ab <vector94>:
.globl vector94
vector94:
  pushl $0
801074ab:	6a 00                	push   $0x0
  pushl $94
801074ad:	6a 5e                	push   $0x5e
  jmp alltraps
801074af:	e9 69 f6 ff ff       	jmp    80106b1d <alltraps>

801074b4 <vector95>:
.globl vector95
vector95:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $95
801074b6:	6a 5f                	push   $0x5f
  jmp alltraps
801074b8:	e9 60 f6 ff ff       	jmp    80106b1d <alltraps>

801074bd <vector96>:
.globl vector96
vector96:
  pushl $0
801074bd:	6a 00                	push   $0x0
  pushl $96
801074bf:	6a 60                	push   $0x60
  jmp alltraps
801074c1:	e9 57 f6 ff ff       	jmp    80106b1d <alltraps>

801074c6 <vector97>:
.globl vector97
vector97:
  pushl $0
801074c6:	6a 00                	push   $0x0
  pushl $97
801074c8:	6a 61                	push   $0x61
  jmp alltraps
801074ca:	e9 4e f6 ff ff       	jmp    80106b1d <alltraps>

801074cf <vector98>:
.globl vector98
vector98:
  pushl $0
801074cf:	6a 00                	push   $0x0
  pushl $98
801074d1:	6a 62                	push   $0x62
  jmp alltraps
801074d3:	e9 45 f6 ff ff       	jmp    80106b1d <alltraps>

801074d8 <vector99>:
.globl vector99
vector99:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $99
801074da:	6a 63                	push   $0x63
  jmp alltraps
801074dc:	e9 3c f6 ff ff       	jmp    80106b1d <alltraps>

801074e1 <vector100>:
.globl vector100
vector100:
  pushl $0
801074e1:	6a 00                	push   $0x0
  pushl $100
801074e3:	6a 64                	push   $0x64
  jmp alltraps
801074e5:	e9 33 f6 ff ff       	jmp    80106b1d <alltraps>

801074ea <vector101>:
.globl vector101
vector101:
  pushl $0
801074ea:	6a 00                	push   $0x0
  pushl $101
801074ec:	6a 65                	push   $0x65
  jmp alltraps
801074ee:	e9 2a f6 ff ff       	jmp    80106b1d <alltraps>

801074f3 <vector102>:
.globl vector102
vector102:
  pushl $0
801074f3:	6a 00                	push   $0x0
  pushl $102
801074f5:	6a 66                	push   $0x66
  jmp alltraps
801074f7:	e9 21 f6 ff ff       	jmp    80106b1d <alltraps>

801074fc <vector103>:
.globl vector103
vector103:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $103
801074fe:	6a 67                	push   $0x67
  jmp alltraps
80107500:	e9 18 f6 ff ff       	jmp    80106b1d <alltraps>

80107505 <vector104>:
.globl vector104
vector104:
  pushl $0
80107505:	6a 00                	push   $0x0
  pushl $104
80107507:	6a 68                	push   $0x68
  jmp alltraps
80107509:	e9 0f f6 ff ff       	jmp    80106b1d <alltraps>

8010750e <vector105>:
.globl vector105
vector105:
  pushl $0
8010750e:	6a 00                	push   $0x0
  pushl $105
80107510:	6a 69                	push   $0x69
  jmp alltraps
80107512:	e9 06 f6 ff ff       	jmp    80106b1d <alltraps>

80107517 <vector106>:
.globl vector106
vector106:
  pushl $0
80107517:	6a 00                	push   $0x0
  pushl $106
80107519:	6a 6a                	push   $0x6a
  jmp alltraps
8010751b:	e9 fd f5 ff ff       	jmp    80106b1d <alltraps>

80107520 <vector107>:
.globl vector107
vector107:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $107
80107522:	6a 6b                	push   $0x6b
  jmp alltraps
80107524:	e9 f4 f5 ff ff       	jmp    80106b1d <alltraps>

80107529 <vector108>:
.globl vector108
vector108:
  pushl $0
80107529:	6a 00                	push   $0x0
  pushl $108
8010752b:	6a 6c                	push   $0x6c
  jmp alltraps
8010752d:	e9 eb f5 ff ff       	jmp    80106b1d <alltraps>

80107532 <vector109>:
.globl vector109
vector109:
  pushl $0
80107532:	6a 00                	push   $0x0
  pushl $109
80107534:	6a 6d                	push   $0x6d
  jmp alltraps
80107536:	e9 e2 f5 ff ff       	jmp    80106b1d <alltraps>

8010753b <vector110>:
.globl vector110
vector110:
  pushl $0
8010753b:	6a 00                	push   $0x0
  pushl $110
8010753d:	6a 6e                	push   $0x6e
  jmp alltraps
8010753f:	e9 d9 f5 ff ff       	jmp    80106b1d <alltraps>

80107544 <vector111>:
.globl vector111
vector111:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $111
80107546:	6a 6f                	push   $0x6f
  jmp alltraps
80107548:	e9 d0 f5 ff ff       	jmp    80106b1d <alltraps>

8010754d <vector112>:
.globl vector112
vector112:
  pushl $0
8010754d:	6a 00                	push   $0x0
  pushl $112
8010754f:	6a 70                	push   $0x70
  jmp alltraps
80107551:	e9 c7 f5 ff ff       	jmp    80106b1d <alltraps>

80107556 <vector113>:
.globl vector113
vector113:
  pushl $0
80107556:	6a 00                	push   $0x0
  pushl $113
80107558:	6a 71                	push   $0x71
  jmp alltraps
8010755a:	e9 be f5 ff ff       	jmp    80106b1d <alltraps>

8010755f <vector114>:
.globl vector114
vector114:
  pushl $0
8010755f:	6a 00                	push   $0x0
  pushl $114
80107561:	6a 72                	push   $0x72
  jmp alltraps
80107563:	e9 b5 f5 ff ff       	jmp    80106b1d <alltraps>

80107568 <vector115>:
.globl vector115
vector115:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $115
8010756a:	6a 73                	push   $0x73
  jmp alltraps
8010756c:	e9 ac f5 ff ff       	jmp    80106b1d <alltraps>

80107571 <vector116>:
.globl vector116
vector116:
  pushl $0
80107571:	6a 00                	push   $0x0
  pushl $116
80107573:	6a 74                	push   $0x74
  jmp alltraps
80107575:	e9 a3 f5 ff ff       	jmp    80106b1d <alltraps>

8010757a <vector117>:
.globl vector117
vector117:
  pushl $0
8010757a:	6a 00                	push   $0x0
  pushl $117
8010757c:	6a 75                	push   $0x75
  jmp alltraps
8010757e:	e9 9a f5 ff ff       	jmp    80106b1d <alltraps>

80107583 <vector118>:
.globl vector118
vector118:
  pushl $0
80107583:	6a 00                	push   $0x0
  pushl $118
80107585:	6a 76                	push   $0x76
  jmp alltraps
80107587:	e9 91 f5 ff ff       	jmp    80106b1d <alltraps>

8010758c <vector119>:
.globl vector119
vector119:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $119
8010758e:	6a 77                	push   $0x77
  jmp alltraps
80107590:	e9 88 f5 ff ff       	jmp    80106b1d <alltraps>

80107595 <vector120>:
.globl vector120
vector120:
  pushl $0
80107595:	6a 00                	push   $0x0
  pushl $120
80107597:	6a 78                	push   $0x78
  jmp alltraps
80107599:	e9 7f f5 ff ff       	jmp    80106b1d <alltraps>

8010759e <vector121>:
.globl vector121
vector121:
  pushl $0
8010759e:	6a 00                	push   $0x0
  pushl $121
801075a0:	6a 79                	push   $0x79
  jmp alltraps
801075a2:	e9 76 f5 ff ff       	jmp    80106b1d <alltraps>

801075a7 <vector122>:
.globl vector122
vector122:
  pushl $0
801075a7:	6a 00                	push   $0x0
  pushl $122
801075a9:	6a 7a                	push   $0x7a
  jmp alltraps
801075ab:	e9 6d f5 ff ff       	jmp    80106b1d <alltraps>

801075b0 <vector123>:
.globl vector123
vector123:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $123
801075b2:	6a 7b                	push   $0x7b
  jmp alltraps
801075b4:	e9 64 f5 ff ff       	jmp    80106b1d <alltraps>

801075b9 <vector124>:
.globl vector124
vector124:
  pushl $0
801075b9:	6a 00                	push   $0x0
  pushl $124
801075bb:	6a 7c                	push   $0x7c
  jmp alltraps
801075bd:	e9 5b f5 ff ff       	jmp    80106b1d <alltraps>

801075c2 <vector125>:
.globl vector125
vector125:
  pushl $0
801075c2:	6a 00                	push   $0x0
  pushl $125
801075c4:	6a 7d                	push   $0x7d
  jmp alltraps
801075c6:	e9 52 f5 ff ff       	jmp    80106b1d <alltraps>

801075cb <vector126>:
.globl vector126
vector126:
  pushl $0
801075cb:	6a 00                	push   $0x0
  pushl $126
801075cd:	6a 7e                	push   $0x7e
  jmp alltraps
801075cf:	e9 49 f5 ff ff       	jmp    80106b1d <alltraps>

801075d4 <vector127>:
.globl vector127
vector127:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $127
801075d6:	6a 7f                	push   $0x7f
  jmp alltraps
801075d8:	e9 40 f5 ff ff       	jmp    80106b1d <alltraps>

801075dd <vector128>:
.globl vector128
vector128:
  pushl $0
801075dd:	6a 00                	push   $0x0
  pushl $128
801075df:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801075e4:	e9 34 f5 ff ff       	jmp    80106b1d <alltraps>

801075e9 <vector129>:
.globl vector129
vector129:
  pushl $0
801075e9:	6a 00                	push   $0x0
  pushl $129
801075eb:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801075f0:	e9 28 f5 ff ff       	jmp    80106b1d <alltraps>

801075f5 <vector130>:
.globl vector130
vector130:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $130
801075f7:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801075fc:	e9 1c f5 ff ff       	jmp    80106b1d <alltraps>

80107601 <vector131>:
.globl vector131
vector131:
  pushl $0
80107601:	6a 00                	push   $0x0
  pushl $131
80107603:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107608:	e9 10 f5 ff ff       	jmp    80106b1d <alltraps>

8010760d <vector132>:
.globl vector132
vector132:
  pushl $0
8010760d:	6a 00                	push   $0x0
  pushl $132
8010760f:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107614:	e9 04 f5 ff ff       	jmp    80106b1d <alltraps>

80107619 <vector133>:
.globl vector133
vector133:
  pushl $0
80107619:	6a 00                	push   $0x0
  pushl $133
8010761b:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107620:	e9 f8 f4 ff ff       	jmp    80106b1d <alltraps>

80107625 <vector134>:
.globl vector134
vector134:
  pushl $0
80107625:	6a 00                	push   $0x0
  pushl $134
80107627:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010762c:	e9 ec f4 ff ff       	jmp    80106b1d <alltraps>

80107631 <vector135>:
.globl vector135
vector135:
  pushl $0
80107631:	6a 00                	push   $0x0
  pushl $135
80107633:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107638:	e9 e0 f4 ff ff       	jmp    80106b1d <alltraps>

8010763d <vector136>:
.globl vector136
vector136:
  pushl $0
8010763d:	6a 00                	push   $0x0
  pushl $136
8010763f:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107644:	e9 d4 f4 ff ff       	jmp    80106b1d <alltraps>

80107649 <vector137>:
.globl vector137
vector137:
  pushl $0
80107649:	6a 00                	push   $0x0
  pushl $137
8010764b:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107650:	e9 c8 f4 ff ff       	jmp    80106b1d <alltraps>

80107655 <vector138>:
.globl vector138
vector138:
  pushl $0
80107655:	6a 00                	push   $0x0
  pushl $138
80107657:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010765c:	e9 bc f4 ff ff       	jmp    80106b1d <alltraps>

80107661 <vector139>:
.globl vector139
vector139:
  pushl $0
80107661:	6a 00                	push   $0x0
  pushl $139
80107663:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107668:	e9 b0 f4 ff ff       	jmp    80106b1d <alltraps>

8010766d <vector140>:
.globl vector140
vector140:
  pushl $0
8010766d:	6a 00                	push   $0x0
  pushl $140
8010766f:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107674:	e9 a4 f4 ff ff       	jmp    80106b1d <alltraps>

80107679 <vector141>:
.globl vector141
vector141:
  pushl $0
80107679:	6a 00                	push   $0x0
  pushl $141
8010767b:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107680:	e9 98 f4 ff ff       	jmp    80106b1d <alltraps>

80107685 <vector142>:
.globl vector142
vector142:
  pushl $0
80107685:	6a 00                	push   $0x0
  pushl $142
80107687:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010768c:	e9 8c f4 ff ff       	jmp    80106b1d <alltraps>

80107691 <vector143>:
.globl vector143
vector143:
  pushl $0
80107691:	6a 00                	push   $0x0
  pushl $143
80107693:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107698:	e9 80 f4 ff ff       	jmp    80106b1d <alltraps>

8010769d <vector144>:
.globl vector144
vector144:
  pushl $0
8010769d:	6a 00                	push   $0x0
  pushl $144
8010769f:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801076a4:	e9 74 f4 ff ff       	jmp    80106b1d <alltraps>

801076a9 <vector145>:
.globl vector145
vector145:
  pushl $0
801076a9:	6a 00                	push   $0x0
  pushl $145
801076ab:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801076b0:	e9 68 f4 ff ff       	jmp    80106b1d <alltraps>

801076b5 <vector146>:
.globl vector146
vector146:
  pushl $0
801076b5:	6a 00                	push   $0x0
  pushl $146
801076b7:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801076bc:	e9 5c f4 ff ff       	jmp    80106b1d <alltraps>

801076c1 <vector147>:
.globl vector147
vector147:
  pushl $0
801076c1:	6a 00                	push   $0x0
  pushl $147
801076c3:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801076c8:	e9 50 f4 ff ff       	jmp    80106b1d <alltraps>

801076cd <vector148>:
.globl vector148
vector148:
  pushl $0
801076cd:	6a 00                	push   $0x0
  pushl $148
801076cf:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801076d4:	e9 44 f4 ff ff       	jmp    80106b1d <alltraps>

801076d9 <vector149>:
.globl vector149
vector149:
  pushl $0
801076d9:	6a 00                	push   $0x0
  pushl $149
801076db:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801076e0:	e9 38 f4 ff ff       	jmp    80106b1d <alltraps>

801076e5 <vector150>:
.globl vector150
vector150:
  pushl $0
801076e5:	6a 00                	push   $0x0
  pushl $150
801076e7:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801076ec:	e9 2c f4 ff ff       	jmp    80106b1d <alltraps>

801076f1 <vector151>:
.globl vector151
vector151:
  pushl $0
801076f1:	6a 00                	push   $0x0
  pushl $151
801076f3:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801076f8:	e9 20 f4 ff ff       	jmp    80106b1d <alltraps>

801076fd <vector152>:
.globl vector152
vector152:
  pushl $0
801076fd:	6a 00                	push   $0x0
  pushl $152
801076ff:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107704:	e9 14 f4 ff ff       	jmp    80106b1d <alltraps>

80107709 <vector153>:
.globl vector153
vector153:
  pushl $0
80107709:	6a 00                	push   $0x0
  pushl $153
8010770b:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107710:	e9 08 f4 ff ff       	jmp    80106b1d <alltraps>

80107715 <vector154>:
.globl vector154
vector154:
  pushl $0
80107715:	6a 00                	push   $0x0
  pushl $154
80107717:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010771c:	e9 fc f3 ff ff       	jmp    80106b1d <alltraps>

80107721 <vector155>:
.globl vector155
vector155:
  pushl $0
80107721:	6a 00                	push   $0x0
  pushl $155
80107723:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107728:	e9 f0 f3 ff ff       	jmp    80106b1d <alltraps>

8010772d <vector156>:
.globl vector156
vector156:
  pushl $0
8010772d:	6a 00                	push   $0x0
  pushl $156
8010772f:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107734:	e9 e4 f3 ff ff       	jmp    80106b1d <alltraps>

80107739 <vector157>:
.globl vector157
vector157:
  pushl $0
80107739:	6a 00                	push   $0x0
  pushl $157
8010773b:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107740:	e9 d8 f3 ff ff       	jmp    80106b1d <alltraps>

80107745 <vector158>:
.globl vector158
vector158:
  pushl $0
80107745:	6a 00                	push   $0x0
  pushl $158
80107747:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010774c:	e9 cc f3 ff ff       	jmp    80106b1d <alltraps>

80107751 <vector159>:
.globl vector159
vector159:
  pushl $0
80107751:	6a 00                	push   $0x0
  pushl $159
80107753:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107758:	e9 c0 f3 ff ff       	jmp    80106b1d <alltraps>

8010775d <vector160>:
.globl vector160
vector160:
  pushl $0
8010775d:	6a 00                	push   $0x0
  pushl $160
8010775f:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107764:	e9 b4 f3 ff ff       	jmp    80106b1d <alltraps>

80107769 <vector161>:
.globl vector161
vector161:
  pushl $0
80107769:	6a 00                	push   $0x0
  pushl $161
8010776b:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107770:	e9 a8 f3 ff ff       	jmp    80106b1d <alltraps>

80107775 <vector162>:
.globl vector162
vector162:
  pushl $0
80107775:	6a 00                	push   $0x0
  pushl $162
80107777:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010777c:	e9 9c f3 ff ff       	jmp    80106b1d <alltraps>

80107781 <vector163>:
.globl vector163
vector163:
  pushl $0
80107781:	6a 00                	push   $0x0
  pushl $163
80107783:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107788:	e9 90 f3 ff ff       	jmp    80106b1d <alltraps>

8010778d <vector164>:
.globl vector164
vector164:
  pushl $0
8010778d:	6a 00                	push   $0x0
  pushl $164
8010778f:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107794:	e9 84 f3 ff ff       	jmp    80106b1d <alltraps>

80107799 <vector165>:
.globl vector165
vector165:
  pushl $0
80107799:	6a 00                	push   $0x0
  pushl $165
8010779b:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801077a0:	e9 78 f3 ff ff       	jmp    80106b1d <alltraps>

801077a5 <vector166>:
.globl vector166
vector166:
  pushl $0
801077a5:	6a 00                	push   $0x0
  pushl $166
801077a7:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801077ac:	e9 6c f3 ff ff       	jmp    80106b1d <alltraps>

801077b1 <vector167>:
.globl vector167
vector167:
  pushl $0
801077b1:	6a 00                	push   $0x0
  pushl $167
801077b3:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801077b8:	e9 60 f3 ff ff       	jmp    80106b1d <alltraps>

801077bd <vector168>:
.globl vector168
vector168:
  pushl $0
801077bd:	6a 00                	push   $0x0
  pushl $168
801077bf:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801077c4:	e9 54 f3 ff ff       	jmp    80106b1d <alltraps>

801077c9 <vector169>:
.globl vector169
vector169:
  pushl $0
801077c9:	6a 00                	push   $0x0
  pushl $169
801077cb:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801077d0:	e9 48 f3 ff ff       	jmp    80106b1d <alltraps>

801077d5 <vector170>:
.globl vector170
vector170:
  pushl $0
801077d5:	6a 00                	push   $0x0
  pushl $170
801077d7:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801077dc:	e9 3c f3 ff ff       	jmp    80106b1d <alltraps>

801077e1 <vector171>:
.globl vector171
vector171:
  pushl $0
801077e1:	6a 00                	push   $0x0
  pushl $171
801077e3:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801077e8:	e9 30 f3 ff ff       	jmp    80106b1d <alltraps>

801077ed <vector172>:
.globl vector172
vector172:
  pushl $0
801077ed:	6a 00                	push   $0x0
  pushl $172
801077ef:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801077f4:	e9 24 f3 ff ff       	jmp    80106b1d <alltraps>

801077f9 <vector173>:
.globl vector173
vector173:
  pushl $0
801077f9:	6a 00                	push   $0x0
  pushl $173
801077fb:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107800:	e9 18 f3 ff ff       	jmp    80106b1d <alltraps>

80107805 <vector174>:
.globl vector174
vector174:
  pushl $0
80107805:	6a 00                	push   $0x0
  pushl $174
80107807:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010780c:	e9 0c f3 ff ff       	jmp    80106b1d <alltraps>

80107811 <vector175>:
.globl vector175
vector175:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $175
80107813:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107818:	e9 00 f3 ff ff       	jmp    80106b1d <alltraps>

8010781d <vector176>:
.globl vector176
vector176:
  pushl $0
8010781d:	6a 00                	push   $0x0
  pushl $176
8010781f:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107824:	e9 f4 f2 ff ff       	jmp    80106b1d <alltraps>

80107829 <vector177>:
.globl vector177
vector177:
  pushl $0
80107829:	6a 00                	push   $0x0
  pushl $177
8010782b:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107830:	e9 e8 f2 ff ff       	jmp    80106b1d <alltraps>

80107835 <vector178>:
.globl vector178
vector178:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $178
80107837:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010783c:	e9 dc f2 ff ff       	jmp    80106b1d <alltraps>

80107841 <vector179>:
.globl vector179
vector179:
  pushl $0
80107841:	6a 00                	push   $0x0
  pushl $179
80107843:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107848:	e9 d0 f2 ff ff       	jmp    80106b1d <alltraps>

8010784d <vector180>:
.globl vector180
vector180:
  pushl $0
8010784d:	6a 00                	push   $0x0
  pushl $180
8010784f:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107854:	e9 c4 f2 ff ff       	jmp    80106b1d <alltraps>

80107859 <vector181>:
.globl vector181
vector181:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $181
8010785b:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107860:	e9 b8 f2 ff ff       	jmp    80106b1d <alltraps>

80107865 <vector182>:
.globl vector182
vector182:
  pushl $0
80107865:	6a 00                	push   $0x0
  pushl $182
80107867:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010786c:	e9 ac f2 ff ff       	jmp    80106b1d <alltraps>

80107871 <vector183>:
.globl vector183
vector183:
  pushl $0
80107871:	6a 00                	push   $0x0
  pushl $183
80107873:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107878:	e9 a0 f2 ff ff       	jmp    80106b1d <alltraps>

8010787d <vector184>:
.globl vector184
vector184:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $184
8010787f:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107884:	e9 94 f2 ff ff       	jmp    80106b1d <alltraps>

80107889 <vector185>:
.globl vector185
vector185:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $185
8010788b:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107890:	e9 88 f2 ff ff       	jmp    80106b1d <alltraps>

80107895 <vector186>:
.globl vector186
vector186:
  pushl $0
80107895:	6a 00                	push   $0x0
  pushl $186
80107897:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010789c:	e9 7c f2 ff ff       	jmp    80106b1d <alltraps>

801078a1 <vector187>:
.globl vector187
vector187:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $187
801078a3:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801078a8:	e9 70 f2 ff ff       	jmp    80106b1d <alltraps>

801078ad <vector188>:
.globl vector188
vector188:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $188
801078af:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801078b4:	e9 64 f2 ff ff       	jmp    80106b1d <alltraps>

801078b9 <vector189>:
.globl vector189
vector189:
  pushl $0
801078b9:	6a 00                	push   $0x0
  pushl $189
801078bb:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801078c0:	e9 58 f2 ff ff       	jmp    80106b1d <alltraps>

801078c5 <vector190>:
.globl vector190
vector190:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $190
801078c7:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801078cc:	e9 4c f2 ff ff       	jmp    80106b1d <alltraps>

801078d1 <vector191>:
.globl vector191
vector191:
  pushl $0
801078d1:	6a 00                	push   $0x0
  pushl $191
801078d3:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801078d8:	e9 40 f2 ff ff       	jmp    80106b1d <alltraps>

801078dd <vector192>:
.globl vector192
vector192:
  pushl $0
801078dd:	6a 00                	push   $0x0
  pushl $192
801078df:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801078e4:	e9 34 f2 ff ff       	jmp    80106b1d <alltraps>

801078e9 <vector193>:
.globl vector193
vector193:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $193
801078eb:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801078f0:	e9 28 f2 ff ff       	jmp    80106b1d <alltraps>

801078f5 <vector194>:
.globl vector194
vector194:
  pushl $0
801078f5:	6a 00                	push   $0x0
  pushl $194
801078f7:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801078fc:	e9 1c f2 ff ff       	jmp    80106b1d <alltraps>

80107901 <vector195>:
.globl vector195
vector195:
  pushl $0
80107901:	6a 00                	push   $0x0
  pushl $195
80107903:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107908:	e9 10 f2 ff ff       	jmp    80106b1d <alltraps>

8010790d <vector196>:
.globl vector196
vector196:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $196
8010790f:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107914:	e9 04 f2 ff ff       	jmp    80106b1d <alltraps>

80107919 <vector197>:
.globl vector197
vector197:
  pushl $0
80107919:	6a 00                	push   $0x0
  pushl $197
8010791b:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107920:	e9 f8 f1 ff ff       	jmp    80106b1d <alltraps>

80107925 <vector198>:
.globl vector198
vector198:
  pushl $0
80107925:	6a 00                	push   $0x0
  pushl $198
80107927:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010792c:	e9 ec f1 ff ff       	jmp    80106b1d <alltraps>

80107931 <vector199>:
.globl vector199
vector199:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $199
80107933:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107938:	e9 e0 f1 ff ff       	jmp    80106b1d <alltraps>

8010793d <vector200>:
.globl vector200
vector200:
  pushl $0
8010793d:	6a 00                	push   $0x0
  pushl $200
8010793f:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107944:	e9 d4 f1 ff ff       	jmp    80106b1d <alltraps>

80107949 <vector201>:
.globl vector201
vector201:
  pushl $0
80107949:	6a 00                	push   $0x0
  pushl $201
8010794b:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107950:	e9 c8 f1 ff ff       	jmp    80106b1d <alltraps>

80107955 <vector202>:
.globl vector202
vector202:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $202
80107957:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010795c:	e9 bc f1 ff ff       	jmp    80106b1d <alltraps>

80107961 <vector203>:
.globl vector203
vector203:
  pushl $0
80107961:	6a 00                	push   $0x0
  pushl $203
80107963:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107968:	e9 b0 f1 ff ff       	jmp    80106b1d <alltraps>

8010796d <vector204>:
.globl vector204
vector204:
  pushl $0
8010796d:	6a 00                	push   $0x0
  pushl $204
8010796f:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107974:	e9 a4 f1 ff ff       	jmp    80106b1d <alltraps>

80107979 <vector205>:
.globl vector205
vector205:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $205
8010797b:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107980:	e9 98 f1 ff ff       	jmp    80106b1d <alltraps>

80107985 <vector206>:
.globl vector206
vector206:
  pushl $0
80107985:	6a 00                	push   $0x0
  pushl $206
80107987:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010798c:	e9 8c f1 ff ff       	jmp    80106b1d <alltraps>

80107991 <vector207>:
.globl vector207
vector207:
  pushl $0
80107991:	6a 00                	push   $0x0
  pushl $207
80107993:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107998:	e9 80 f1 ff ff       	jmp    80106b1d <alltraps>

8010799d <vector208>:
.globl vector208
vector208:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $208
8010799f:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801079a4:	e9 74 f1 ff ff       	jmp    80106b1d <alltraps>

801079a9 <vector209>:
.globl vector209
vector209:
  pushl $0
801079a9:	6a 00                	push   $0x0
  pushl $209
801079ab:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801079b0:	e9 68 f1 ff ff       	jmp    80106b1d <alltraps>

801079b5 <vector210>:
.globl vector210
vector210:
  pushl $0
801079b5:	6a 00                	push   $0x0
  pushl $210
801079b7:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801079bc:	e9 5c f1 ff ff       	jmp    80106b1d <alltraps>

801079c1 <vector211>:
.globl vector211
vector211:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $211
801079c3:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801079c8:	e9 50 f1 ff ff       	jmp    80106b1d <alltraps>

801079cd <vector212>:
.globl vector212
vector212:
  pushl $0
801079cd:	6a 00                	push   $0x0
  pushl $212
801079cf:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801079d4:	e9 44 f1 ff ff       	jmp    80106b1d <alltraps>

801079d9 <vector213>:
.globl vector213
vector213:
  pushl $0
801079d9:	6a 00                	push   $0x0
  pushl $213
801079db:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801079e0:	e9 38 f1 ff ff       	jmp    80106b1d <alltraps>

801079e5 <vector214>:
.globl vector214
vector214:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $214
801079e7:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801079ec:	e9 2c f1 ff ff       	jmp    80106b1d <alltraps>

801079f1 <vector215>:
.globl vector215
vector215:
  pushl $0
801079f1:	6a 00                	push   $0x0
  pushl $215
801079f3:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801079f8:	e9 20 f1 ff ff       	jmp    80106b1d <alltraps>

801079fd <vector216>:
.globl vector216
vector216:
  pushl $0
801079fd:	6a 00                	push   $0x0
  pushl $216
801079ff:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107a04:	e9 14 f1 ff ff       	jmp    80106b1d <alltraps>

80107a09 <vector217>:
.globl vector217
vector217:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $217
80107a0b:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107a10:	e9 08 f1 ff ff       	jmp    80106b1d <alltraps>

80107a15 <vector218>:
.globl vector218
vector218:
  pushl $0
80107a15:	6a 00                	push   $0x0
  pushl $218
80107a17:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107a1c:	e9 fc f0 ff ff       	jmp    80106b1d <alltraps>

80107a21 <vector219>:
.globl vector219
vector219:
  pushl $0
80107a21:	6a 00                	push   $0x0
  pushl $219
80107a23:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107a28:	e9 f0 f0 ff ff       	jmp    80106b1d <alltraps>

80107a2d <vector220>:
.globl vector220
vector220:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $220
80107a2f:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107a34:	e9 e4 f0 ff ff       	jmp    80106b1d <alltraps>

80107a39 <vector221>:
.globl vector221
vector221:
  pushl $0
80107a39:	6a 00                	push   $0x0
  pushl $221
80107a3b:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107a40:	e9 d8 f0 ff ff       	jmp    80106b1d <alltraps>

80107a45 <vector222>:
.globl vector222
vector222:
  pushl $0
80107a45:	6a 00                	push   $0x0
  pushl $222
80107a47:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107a4c:	e9 cc f0 ff ff       	jmp    80106b1d <alltraps>

80107a51 <vector223>:
.globl vector223
vector223:
  pushl $0
80107a51:	6a 00                	push   $0x0
  pushl $223
80107a53:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107a58:	e9 c0 f0 ff ff       	jmp    80106b1d <alltraps>

80107a5d <vector224>:
.globl vector224
vector224:
  pushl $0
80107a5d:	6a 00                	push   $0x0
  pushl $224
80107a5f:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107a64:	e9 b4 f0 ff ff       	jmp    80106b1d <alltraps>

80107a69 <vector225>:
.globl vector225
vector225:
  pushl $0
80107a69:	6a 00                	push   $0x0
  pushl $225
80107a6b:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107a70:	e9 a8 f0 ff ff       	jmp    80106b1d <alltraps>

80107a75 <vector226>:
.globl vector226
vector226:
  pushl $0
80107a75:	6a 00                	push   $0x0
  pushl $226
80107a77:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107a7c:	e9 9c f0 ff ff       	jmp    80106b1d <alltraps>

80107a81 <vector227>:
.globl vector227
vector227:
  pushl $0
80107a81:	6a 00                	push   $0x0
  pushl $227
80107a83:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107a88:	e9 90 f0 ff ff       	jmp    80106b1d <alltraps>

80107a8d <vector228>:
.globl vector228
vector228:
  pushl $0
80107a8d:	6a 00                	push   $0x0
  pushl $228
80107a8f:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107a94:	e9 84 f0 ff ff       	jmp    80106b1d <alltraps>

80107a99 <vector229>:
.globl vector229
vector229:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $229
80107a9b:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107aa0:	e9 78 f0 ff ff       	jmp    80106b1d <alltraps>

80107aa5 <vector230>:
.globl vector230
vector230:
  pushl $0
80107aa5:	6a 00                	push   $0x0
  pushl $230
80107aa7:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107aac:	e9 6c f0 ff ff       	jmp    80106b1d <alltraps>

80107ab1 <vector231>:
.globl vector231
vector231:
  pushl $0
80107ab1:	6a 00                	push   $0x0
  pushl $231
80107ab3:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107ab8:	e9 60 f0 ff ff       	jmp    80106b1d <alltraps>

80107abd <vector232>:
.globl vector232
vector232:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $232
80107abf:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ac4:	e9 54 f0 ff ff       	jmp    80106b1d <alltraps>

80107ac9 <vector233>:
.globl vector233
vector233:
  pushl $0
80107ac9:	6a 00                	push   $0x0
  pushl $233
80107acb:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ad0:	e9 48 f0 ff ff       	jmp    80106b1d <alltraps>

80107ad5 <vector234>:
.globl vector234
vector234:
  pushl $0
80107ad5:	6a 00                	push   $0x0
  pushl $234
80107ad7:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107adc:	e9 3c f0 ff ff       	jmp    80106b1d <alltraps>

80107ae1 <vector235>:
.globl vector235
vector235:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $235
80107ae3:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107ae8:	e9 30 f0 ff ff       	jmp    80106b1d <alltraps>

80107aed <vector236>:
.globl vector236
vector236:
  pushl $0
80107aed:	6a 00                	push   $0x0
  pushl $236
80107aef:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107af4:	e9 24 f0 ff ff       	jmp    80106b1d <alltraps>

80107af9 <vector237>:
.globl vector237
vector237:
  pushl $0
80107af9:	6a 00                	push   $0x0
  pushl $237
80107afb:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107b00:	e9 18 f0 ff ff       	jmp    80106b1d <alltraps>

80107b05 <vector238>:
.globl vector238
vector238:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $238
80107b07:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107b0c:	e9 0c f0 ff ff       	jmp    80106b1d <alltraps>

80107b11 <vector239>:
.globl vector239
vector239:
  pushl $0
80107b11:	6a 00                	push   $0x0
  pushl $239
80107b13:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107b18:	e9 00 f0 ff ff       	jmp    80106b1d <alltraps>

80107b1d <vector240>:
.globl vector240
vector240:
  pushl $0
80107b1d:	6a 00                	push   $0x0
  pushl $240
80107b1f:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107b24:	e9 f4 ef ff ff       	jmp    80106b1d <alltraps>

80107b29 <vector241>:
.globl vector241
vector241:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $241
80107b2b:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107b30:	e9 e8 ef ff ff       	jmp    80106b1d <alltraps>

80107b35 <vector242>:
.globl vector242
vector242:
  pushl $0
80107b35:	6a 00                	push   $0x0
  pushl $242
80107b37:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107b3c:	e9 dc ef ff ff       	jmp    80106b1d <alltraps>

80107b41 <vector243>:
.globl vector243
vector243:
  pushl $0
80107b41:	6a 00                	push   $0x0
  pushl $243
80107b43:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107b48:	e9 d0 ef ff ff       	jmp    80106b1d <alltraps>

80107b4d <vector244>:
.globl vector244
vector244:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $244
80107b4f:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107b54:	e9 c4 ef ff ff       	jmp    80106b1d <alltraps>

80107b59 <vector245>:
.globl vector245
vector245:
  pushl $0
80107b59:	6a 00                	push   $0x0
  pushl $245
80107b5b:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107b60:	e9 b8 ef ff ff       	jmp    80106b1d <alltraps>

80107b65 <vector246>:
.globl vector246
vector246:
  pushl $0
80107b65:	6a 00                	push   $0x0
  pushl $246
80107b67:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107b6c:	e9 ac ef ff ff       	jmp    80106b1d <alltraps>

80107b71 <vector247>:
.globl vector247
vector247:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $247
80107b73:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107b78:	e9 a0 ef ff ff       	jmp    80106b1d <alltraps>

80107b7d <vector248>:
.globl vector248
vector248:
  pushl $0
80107b7d:	6a 00                	push   $0x0
  pushl $248
80107b7f:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107b84:	e9 94 ef ff ff       	jmp    80106b1d <alltraps>

80107b89 <vector249>:
.globl vector249
vector249:
  pushl $0
80107b89:	6a 00                	push   $0x0
  pushl $249
80107b8b:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107b90:	e9 88 ef ff ff       	jmp    80106b1d <alltraps>

80107b95 <vector250>:
.globl vector250
vector250:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $250
80107b97:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107b9c:	e9 7c ef ff ff       	jmp    80106b1d <alltraps>

80107ba1 <vector251>:
.globl vector251
vector251:
  pushl $0
80107ba1:	6a 00                	push   $0x0
  pushl $251
80107ba3:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107ba8:	e9 70 ef ff ff       	jmp    80106b1d <alltraps>

80107bad <vector252>:
.globl vector252
vector252:
  pushl $0
80107bad:	6a 00                	push   $0x0
  pushl $252
80107baf:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107bb4:	e9 64 ef ff ff       	jmp    80106b1d <alltraps>

80107bb9 <vector253>:
.globl vector253
vector253:
  pushl $0
80107bb9:	6a 00                	push   $0x0
  pushl $253
80107bbb:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107bc0:	e9 58 ef ff ff       	jmp    80106b1d <alltraps>

80107bc5 <vector254>:
.globl vector254
vector254:
  pushl $0
80107bc5:	6a 00                	push   $0x0
  pushl $254
80107bc7:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107bcc:	e9 4c ef ff ff       	jmp    80106b1d <alltraps>

80107bd1 <vector255>:
.globl vector255
vector255:
  pushl $0
80107bd1:	6a 00                	push   $0x0
  pushl $255
80107bd3:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107bd8:	e9 40 ef ff ff       	jmp    80106b1d <alltraps>

80107bdd <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107bdd:	55                   	push   %ebp
80107bde:	89 e5                	mov    %esp,%ebp
80107be0:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107be3:	8b 45 0c             	mov    0xc(%ebp),%eax
80107be6:	83 e8 01             	sub    $0x1,%eax
80107be9:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107bed:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107bf4:	8b 45 08             	mov    0x8(%ebp),%eax
80107bf7:	c1 e8 10             	shr    $0x10,%eax
80107bfa:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107bfe:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107c01:	0f 01 10             	lgdtl  (%eax)
}
80107c04:	90                   	nop
80107c05:	c9                   	leave  
80107c06:	c3                   	ret    

80107c07 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107c07:	55                   	push   %ebp
80107c08:	89 e5                	mov    %esp,%ebp
80107c0a:	83 ec 04             	sub    $0x4,%esp
80107c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80107c10:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107c14:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c18:	0f 00 d8             	ltr    %ax
}
80107c1b:	90                   	nop
80107c1c:	c9                   	leave  
80107c1d:	c3                   	ret    

80107c1e <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107c1e:	55                   	push   %ebp
80107c1f:	89 e5                	mov    %esp,%ebp
80107c21:	83 ec 04             	sub    $0x4,%esp
80107c24:	8b 45 08             	mov    0x8(%ebp),%eax
80107c27:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107c2b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107c2f:	8e e8                	mov    %eax,%gs
}
80107c31:	90                   	nop
80107c32:	c9                   	leave  
80107c33:	c3                   	ret    

80107c34 <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
80107c34:	55                   	push   %ebp
80107c35:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107c37:	8b 45 08             	mov    0x8(%ebp),%eax
80107c3a:	0f 22 d8             	mov    %eax,%cr3
}
80107c3d:	90                   	nop
80107c3e:	5d                   	pop    %ebp
80107c3f:	c3                   	ret    

80107c40 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107c40:	55                   	push   %ebp
80107c41:	89 e5                	mov    %esp,%ebp
80107c43:	8b 45 08             	mov    0x8(%ebp),%eax
80107c46:	05 00 00 00 80       	add    $0x80000000,%eax
80107c4b:	5d                   	pop    %ebp
80107c4c:	c3                   	ret    

80107c4d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107c4d:	55                   	push   %ebp
80107c4e:	89 e5                	mov    %esp,%ebp
80107c50:	8b 45 08             	mov    0x8(%ebp),%eax
80107c53:	05 00 00 00 80       	add    $0x80000000,%eax
80107c58:	5d                   	pop    %ebp
80107c59:	c3                   	ret    

80107c5a <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107c5a:	55                   	push   %ebp
80107c5b:	89 e5                	mov    %esp,%ebp
80107c5d:	53                   	push   %ebx
80107c5e:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80107c61:	e8 66 b3 ff ff       	call   80102fcc <cpunum>
80107c66:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80107c6c:	05 80 33 11 80       	add    $0x80113380,%eax
80107c71:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107c74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c77:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c80:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c90:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107c94:	83 e2 f0             	and    $0xfffffff0,%edx
80107c97:	83 ca 0a             	or     $0xa,%edx
80107c9a:	88 50 7d             	mov    %dl,0x7d(%eax)
80107c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ca0:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107ca4:	83 ca 10             	or     $0x10,%edx
80107ca7:	88 50 7d             	mov    %dl,0x7d(%eax)
80107caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cad:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cb1:	83 e2 9f             	and    $0xffffff9f,%edx
80107cb4:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cba:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107cbe:	83 ca 80             	or     $0xffffff80,%edx
80107cc1:	88 50 7d             	mov    %dl,0x7d(%eax)
80107cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc7:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ccb:	83 ca 0f             	or     $0xf,%edx
80107cce:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cd8:	83 e2 ef             	and    $0xffffffef,%edx
80107cdb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107ce5:	83 e2 df             	and    $0xffffffdf,%edx
80107ce8:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cee:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cf2:	83 ca 40             	or     $0x40,%edx
80107cf5:	88 50 7e             	mov    %dl,0x7e(%eax)
80107cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfb:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107cff:	83 ca 80             	or     $0xffffff80,%edx
80107d02:	88 50 7e             	mov    %dl,0x7e(%eax)
80107d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d08:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0f:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107d16:	ff ff 
80107d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d1b:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107d22:	00 00 
80107d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d27:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d31:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d38:	83 e2 f0             	and    $0xfffffff0,%edx
80107d3b:	83 ca 02             	or     $0x2,%edx
80107d3e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d47:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d4e:	83 ca 10             	or     $0x10,%edx
80107d51:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d61:	83 e2 9f             	and    $0xffffff9f,%edx
80107d64:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6d:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107d74:	83 ca 80             	or     $0xffffff80,%edx
80107d77:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d80:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d87:	83 ca 0f             	or     $0xf,%edx
80107d8a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d93:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107d9a:	83 e2 ef             	and    $0xffffffef,%edx
80107d9d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dad:	83 e2 df             	and    $0xffffffdf,%edx
80107db0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dc0:	83 ca 40             	or     $0x40,%edx
80107dc3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcc:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107dd3:	83 ca 80             	or     $0xffffff80,%edx
80107dd6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ddf:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de9:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107df0:	ff ff 
80107df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107df5:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107dfc:	00 00 
80107dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e01:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e12:	83 e2 f0             	and    $0xfffffff0,%edx
80107e15:	83 ca 0a             	or     $0xa,%edx
80107e18:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e21:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e28:	83 ca 10             	or     $0x10,%edx
80107e2b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e34:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e3b:	83 ca 60             	or     $0x60,%edx
80107e3e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e47:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107e4e:	83 ca 80             	or     $0xffffff80,%edx
80107e51:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e5a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e61:	83 ca 0f             	or     $0xf,%edx
80107e64:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e6d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e74:	83 e2 ef             	and    $0xffffffef,%edx
80107e77:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e80:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e87:	83 e2 df             	and    $0xffffffdf,%edx
80107e8a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e93:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107e9a:	83 ca 40             	or     $0x40,%edx
80107e9d:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107ead:	83 ca 80             	or     $0xffffff80,%edx
80107eb0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eb9:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec3:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107eca:	ff ff 
80107ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ecf:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107ed6:	00 00 
80107ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107edb:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ee5:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107eec:	83 e2 f0             	and    $0xfffffff0,%edx
80107eef:	83 ca 02             	or     $0x2,%edx
80107ef2:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107efb:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f02:	83 ca 10             	or     $0x10,%edx
80107f05:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f0e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f15:	83 ca 60             	or     $0x60,%edx
80107f18:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f21:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107f28:	83 ca 80             	or     $0xffffff80,%edx
80107f2b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f34:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f3b:	83 ca 0f             	or     $0xf,%edx
80107f3e:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f47:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f4e:	83 e2 ef             	and    $0xffffffef,%edx
80107f51:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f61:	83 e2 df             	and    $0xffffffdf,%edx
80107f64:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6d:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f74:	83 ca 40             	or     $0x40,%edx
80107f77:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f80:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107f87:	83 ca 80             	or     $0xffffff80,%edx
80107f8a:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f93:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9d:	05 b4 00 00 00       	add    $0xb4,%eax
80107fa2:	89 c3                	mov    %eax,%ebx
80107fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa7:	05 b4 00 00 00       	add    $0xb4,%eax
80107fac:	c1 e8 10             	shr    $0x10,%eax
80107faf:	89 c2                	mov    %eax,%edx
80107fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb4:	05 b4 00 00 00       	add    $0xb4,%eax
80107fb9:	c1 e8 18             	shr    $0x18,%eax
80107fbc:	89 c1                	mov    %eax,%ecx
80107fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc1:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107fc8:	00 00 
80107fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcd:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd7:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe0:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107fe7:	83 e2 f0             	and    $0xfffffff0,%edx
80107fea:	83 ca 02             	or     $0x2,%edx
80107fed:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff6:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107ffd:	83 ca 10             	or     $0x10,%edx
80108000:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108009:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108010:	83 e2 9f             	and    $0xffffff9f,%edx
80108013:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108023:	83 ca 80             	or     $0xffffff80,%edx
80108026:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010802c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010802f:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108036:	83 e2 f0             	and    $0xfffffff0,%edx
80108039:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010803f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108042:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108049:	83 e2 ef             	and    $0xffffffef,%edx
8010804c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108055:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010805c:	83 e2 df             	and    $0xffffffdf,%edx
8010805f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108068:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010806f:	83 ca 40             	or     $0x40,%edx
80108072:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010807b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108082:	83 ca 80             	or     $0xffffff80,%edx
80108085:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010808b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010808e:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108094:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108097:	83 c0 70             	add    $0x70,%eax
8010809a:	83 ec 08             	sub    $0x8,%esp
8010809d:	6a 38                	push   $0x38
8010809f:	50                   	push   %eax
801080a0:	e8 38 fb ff ff       	call   80107bdd <lgdt>
801080a5:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801080a8:	83 ec 0c             	sub    $0xc,%esp
801080ab:	6a 18                	push   $0x18
801080ad:	e8 6c fb ff ff       	call   80107c1e <loadgs>
801080b2:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801080b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b8:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801080be:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801080c5:	00 00 00 00 
}
801080c9:	90                   	nop
801080ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080cd:	c9                   	leave  
801080ce:	c3                   	ret    

801080cf <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801080cf:	55                   	push   %ebp
801080d0:	89 e5                	mov    %esp,%ebp
801080d2:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801080d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801080d8:	c1 e8 16             	shr    $0x16,%eax
801080db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801080e2:	8b 45 08             	mov    0x8(%ebp),%eax
801080e5:	01 d0                	add    %edx,%eax
801080e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801080ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080ed:	8b 00                	mov    (%eax),%eax
801080ef:	83 e0 01             	and    $0x1,%eax
801080f2:	85 c0                	test   %eax,%eax
801080f4:	74 18                	je     8010810e <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
801080f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801080f9:	8b 00                	mov    (%eax),%eax
801080fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108100:	50                   	push   %eax
80108101:	e8 47 fb ff ff       	call   80107c4d <p2v>
80108106:	83 c4 04             	add    $0x4,%esp
80108109:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010810c:	eb 48                	jmp    80108156 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010810e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108112:	74 0e                	je     80108122 <walkpgdir+0x53>
80108114:	e8 4d ab ff ff       	call   80102c66 <kalloc>
80108119:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010811c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108120:	75 07                	jne    80108129 <walkpgdir+0x5a>
      return 0;
80108122:	b8 00 00 00 00       	mov    $0x0,%eax
80108127:	eb 44                	jmp    8010816d <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108129:	83 ec 04             	sub    $0x4,%esp
8010812c:	68 00 10 00 00       	push   $0x1000
80108131:	6a 00                	push   $0x0
80108133:	ff 75 f4             	pushl  -0xc(%ebp)
80108136:	e8 c6 d4 ff ff       	call   80105601 <memset>
8010813b:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
8010813e:	83 ec 0c             	sub    $0xc,%esp
80108141:	ff 75 f4             	pushl  -0xc(%ebp)
80108144:	e8 f7 fa ff ff       	call   80107c40 <v2p>
80108149:	83 c4 10             	add    $0x10,%esp
8010814c:	83 c8 07             	or     $0x7,%eax
8010814f:	89 c2                	mov    %eax,%edx
80108151:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108154:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108156:	8b 45 0c             	mov    0xc(%ebp),%eax
80108159:	c1 e8 0c             	shr    $0xc,%eax
8010815c:	25 ff 03 00 00       	and    $0x3ff,%eax
80108161:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816b:	01 d0                	add    %edx,%eax
}
8010816d:	c9                   	leave  
8010816e:	c3                   	ret    

8010816f <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010816f:	55                   	push   %ebp
80108170:	89 e5                	mov    %esp,%ebp
80108172:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108175:	8b 45 0c             	mov    0xc(%ebp),%eax
80108178:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010817d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108180:	8b 55 0c             	mov    0xc(%ebp),%edx
80108183:	8b 45 10             	mov    0x10(%ebp),%eax
80108186:	01 d0                	add    %edx,%eax
80108188:	83 e8 01             	sub    $0x1,%eax
8010818b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108190:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108193:	83 ec 04             	sub    $0x4,%esp
80108196:	6a 01                	push   $0x1
80108198:	ff 75 f4             	pushl  -0xc(%ebp)
8010819b:	ff 75 08             	pushl  0x8(%ebp)
8010819e:	e8 2c ff ff ff       	call   801080cf <walkpgdir>
801081a3:	83 c4 10             	add    $0x10,%esp
801081a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801081a9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801081ad:	75 07                	jne    801081b6 <mappages+0x47>
      return -1;
801081af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801081b4:	eb 47                	jmp    801081fd <mappages+0x8e>
    if(*pte & PTE_P)
801081b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081b9:	8b 00                	mov    (%eax),%eax
801081bb:	83 e0 01             	and    $0x1,%eax
801081be:	85 c0                	test   %eax,%eax
801081c0:	74 0d                	je     801081cf <mappages+0x60>
      panic("remap");
801081c2:	83 ec 0c             	sub    $0xc,%esp
801081c5:	68 70 90 10 80       	push   $0x80109070
801081ca:	e8 97 83 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801081cf:	8b 45 18             	mov    0x18(%ebp),%eax
801081d2:	0b 45 14             	or     0x14(%ebp),%eax
801081d5:	83 c8 01             	or     $0x1,%eax
801081d8:	89 c2                	mov    %eax,%edx
801081da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801081dd:	89 10                	mov    %edx,(%eax)
    if(a == last)
801081df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801081e5:	74 10                	je     801081f7 <mappages+0x88>
      break;
    a += PGSIZE;
801081e7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801081ee:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801081f5:	eb 9c                	jmp    80108193 <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
801081f7:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801081f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801081fd:	c9                   	leave  
801081fe:	c3                   	ret    

801081ff <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801081ff:	55                   	push   %ebp
80108200:	89 e5                	mov    %esp,%ebp
80108202:	53                   	push   %ebx
80108203:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108206:	e8 5b aa ff ff       	call   80102c66 <kalloc>
8010820b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010820e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108212:	75 0a                	jne    8010821e <setupkvm+0x1f>
    return 0;
80108214:	b8 00 00 00 00       	mov    $0x0,%eax
80108219:	e9 8e 00 00 00       	jmp    801082ac <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
8010821e:	83 ec 04             	sub    $0x4,%esp
80108221:	68 00 10 00 00       	push   $0x1000
80108226:	6a 00                	push   $0x0
80108228:	ff 75 f0             	pushl  -0x10(%ebp)
8010822b:	e8 d1 d3 ff ff       	call   80105601 <memset>
80108230:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108233:	83 ec 0c             	sub    $0xc,%esp
80108236:	68 00 00 00 0e       	push   $0xe000000
8010823b:	e8 0d fa ff ff       	call   80107c4d <p2v>
80108240:	83 c4 10             	add    $0x10,%esp
80108243:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108248:	76 0d                	jbe    80108257 <setupkvm+0x58>
    panic("PHYSTOP too high");
8010824a:	83 ec 0c             	sub    $0xc,%esp
8010824d:	68 76 90 10 80       	push   $0x80109076
80108252:	e8 0f 83 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108257:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
8010825e:	eb 40                	jmp    801082a0 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108260:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108263:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80108266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108269:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
8010826c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826f:	8b 58 08             	mov    0x8(%eax),%ebx
80108272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108275:	8b 40 04             	mov    0x4(%eax),%eax
80108278:	29 c3                	sub    %eax,%ebx
8010827a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827d:	8b 00                	mov    (%eax),%eax
8010827f:	83 ec 0c             	sub    $0xc,%esp
80108282:	51                   	push   %ecx
80108283:	52                   	push   %edx
80108284:	53                   	push   %ebx
80108285:	50                   	push   %eax
80108286:	ff 75 f0             	pushl  -0x10(%ebp)
80108289:	e8 e1 fe ff ff       	call   8010816f <mappages>
8010828e:	83 c4 20             	add    $0x20,%esp
80108291:	85 c0                	test   %eax,%eax
80108293:	79 07                	jns    8010829c <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80108295:	b8 00 00 00 00       	mov    $0x0,%eax
8010829a:	eb 10                	jmp    801082ac <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010829c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801082a0:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801082a7:	72 b7                	jb     80108260 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801082a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801082ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801082af:	c9                   	leave  
801082b0:	c3                   	ret    

801082b1 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801082b1:	55                   	push   %ebp
801082b2:	89 e5                	mov    %esp,%ebp
801082b4:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801082b7:	e8 43 ff ff ff       	call   801081ff <setupkvm>
801082bc:	a3 18 66 11 80       	mov    %eax,0x80116618
  switchkvm();
801082c1:	e8 03 00 00 00       	call   801082c9 <switchkvm>
}
801082c6:	90                   	nop
801082c7:	c9                   	leave  
801082c8:	c3                   	ret    

801082c9 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801082c9:	55                   	push   %ebp
801082ca:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801082cc:	a1 18 66 11 80       	mov    0x80116618,%eax
801082d1:	50                   	push   %eax
801082d2:	e8 69 f9 ff ff       	call   80107c40 <v2p>
801082d7:	83 c4 04             	add    $0x4,%esp
801082da:	50                   	push   %eax
801082db:	e8 54 f9 ff ff       	call   80107c34 <lcr3>
801082e0:	83 c4 04             	add    $0x4,%esp
}
801082e3:	90                   	nop
801082e4:	c9                   	leave  
801082e5:	c3                   	ret    

801082e6 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801082e6:	55                   	push   %ebp
801082e7:	89 e5                	mov    %esp,%ebp
801082e9:	56                   	push   %esi
801082ea:	53                   	push   %ebx
  pushcli();
801082eb:	e8 0b d2 ff ff       	call   801054fb <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
801082f0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801082f6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801082fd:	83 c2 08             	add    $0x8,%edx
80108300:	89 d6                	mov    %edx,%esi
80108302:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108309:	83 c2 08             	add    $0x8,%edx
8010830c:	c1 ea 10             	shr    $0x10,%edx
8010830f:	89 d3                	mov    %edx,%ebx
80108311:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108318:	83 c2 08             	add    $0x8,%edx
8010831b:	c1 ea 18             	shr    $0x18,%edx
8010831e:	89 d1                	mov    %edx,%ecx
80108320:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108327:	67 00 
80108329:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108330:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108336:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010833d:	83 e2 f0             	and    $0xfffffff0,%edx
80108340:	83 ca 09             	or     $0x9,%edx
80108343:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108349:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108350:	83 ca 10             	or     $0x10,%edx
80108353:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108359:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108360:	83 e2 9f             	and    $0xffffff9f,%edx
80108363:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108369:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108370:	83 ca 80             	or     $0xffffff80,%edx
80108373:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108379:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108380:	83 e2 f0             	and    $0xfffffff0,%edx
80108383:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108389:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108390:	83 e2 ef             	and    $0xffffffef,%edx
80108393:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108399:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801083a0:	83 e2 df             	and    $0xffffffdf,%edx
801083a3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801083a9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801083b0:	83 ca 40             	or     $0x40,%edx
801083b3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801083b9:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801083c0:	83 e2 7f             	and    $0x7f,%edx
801083c3:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801083c9:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801083cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083d5:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801083dc:	83 e2 ef             	and    $0xffffffef,%edx
801083df:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
801083e5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083eb:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
801083f1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801083f7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801083fe:	8b 52 08             	mov    0x8(%edx),%edx
80108401:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108407:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010840a:	83 ec 0c             	sub    $0xc,%esp
8010840d:	6a 30                	push   $0x30
8010840f:	e8 f3 f7 ff ff       	call   80107c07 <ltr>
80108414:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108417:	8b 45 08             	mov    0x8(%ebp),%eax
8010841a:	8b 40 04             	mov    0x4(%eax),%eax
8010841d:	85 c0                	test   %eax,%eax
8010841f:	75 0d                	jne    8010842e <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108421:	83 ec 0c             	sub    $0xc,%esp
80108424:	68 87 90 10 80       	push   $0x80109087
80108429:	e8 38 81 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
8010842e:	8b 45 08             	mov    0x8(%ebp),%eax
80108431:	8b 40 04             	mov    0x4(%eax),%eax
80108434:	83 ec 0c             	sub    $0xc,%esp
80108437:	50                   	push   %eax
80108438:	e8 03 f8 ff ff       	call   80107c40 <v2p>
8010843d:	83 c4 10             	add    $0x10,%esp
80108440:	83 ec 0c             	sub    $0xc,%esp
80108443:	50                   	push   %eax
80108444:	e8 eb f7 ff ff       	call   80107c34 <lcr3>
80108449:	83 c4 10             	add    $0x10,%esp
  popcli();
8010844c:	e8 ef d0 ff ff       	call   80105540 <popcli>
}
80108451:	90                   	nop
80108452:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108455:	5b                   	pop    %ebx
80108456:	5e                   	pop    %esi
80108457:	5d                   	pop    %ebp
80108458:	c3                   	ret    

80108459 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108459:	55                   	push   %ebp
8010845a:	89 e5                	mov    %esp,%ebp
8010845c:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
8010845f:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108466:	76 0d                	jbe    80108475 <inituvm+0x1c>
    panic("inituvm: more than a page");
80108468:	83 ec 0c             	sub    $0xc,%esp
8010846b:	68 9b 90 10 80       	push   $0x8010909b
80108470:	e8 f1 80 ff ff       	call   80100566 <panic>
  mem = kalloc();
80108475:	e8 ec a7 ff ff       	call   80102c66 <kalloc>
8010847a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010847d:	83 ec 04             	sub    $0x4,%esp
80108480:	68 00 10 00 00       	push   $0x1000
80108485:	6a 00                	push   $0x0
80108487:	ff 75 f4             	pushl  -0xc(%ebp)
8010848a:	e8 72 d1 ff ff       	call   80105601 <memset>
8010848f:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108492:	83 ec 0c             	sub    $0xc,%esp
80108495:	ff 75 f4             	pushl  -0xc(%ebp)
80108498:	e8 a3 f7 ff ff       	call   80107c40 <v2p>
8010849d:	83 c4 10             	add    $0x10,%esp
801084a0:	83 ec 0c             	sub    $0xc,%esp
801084a3:	6a 06                	push   $0x6
801084a5:	50                   	push   %eax
801084a6:	68 00 10 00 00       	push   $0x1000
801084ab:	6a 00                	push   $0x0
801084ad:	ff 75 08             	pushl  0x8(%ebp)
801084b0:	e8 ba fc ff ff       	call   8010816f <mappages>
801084b5:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801084b8:	83 ec 04             	sub    $0x4,%esp
801084bb:	ff 75 10             	pushl  0x10(%ebp)
801084be:	ff 75 0c             	pushl  0xc(%ebp)
801084c1:	ff 75 f4             	pushl  -0xc(%ebp)
801084c4:	e8 f7 d1 ff ff       	call   801056c0 <memmove>
801084c9:	83 c4 10             	add    $0x10,%esp
}
801084cc:	90                   	nop
801084cd:	c9                   	leave  
801084ce:	c3                   	ret    

801084cf <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801084cf:	55                   	push   %ebp
801084d0:	89 e5                	mov    %esp,%ebp
801084d2:	53                   	push   %ebx
801084d3:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801084d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801084d9:	25 ff 0f 00 00       	and    $0xfff,%eax
801084de:	85 c0                	test   %eax,%eax
801084e0:	74 0d                	je     801084ef <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
801084e2:	83 ec 0c             	sub    $0xc,%esp
801084e5:	68 b8 90 10 80       	push   $0x801090b8
801084ea:	e8 77 80 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801084ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084f6:	e9 95 00 00 00       	jmp    80108590 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801084fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801084fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108501:	01 d0                	add    %edx,%eax
80108503:	83 ec 04             	sub    $0x4,%esp
80108506:	6a 00                	push   $0x0
80108508:	50                   	push   %eax
80108509:	ff 75 08             	pushl  0x8(%ebp)
8010850c:	e8 be fb ff ff       	call   801080cf <walkpgdir>
80108511:	83 c4 10             	add    $0x10,%esp
80108514:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108517:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010851b:	75 0d                	jne    8010852a <loaduvm+0x5b>
      panic("loaduvm: address should exist");
8010851d:	83 ec 0c             	sub    $0xc,%esp
80108520:	68 db 90 10 80       	push   $0x801090db
80108525:	e8 3c 80 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010852a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010852d:	8b 00                	mov    (%eax),%eax
8010852f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108534:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108537:	8b 45 18             	mov    0x18(%ebp),%eax
8010853a:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010853d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108542:	77 0b                	ja     8010854f <loaduvm+0x80>
      n = sz - i;
80108544:	8b 45 18             	mov    0x18(%ebp),%eax
80108547:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010854a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010854d:	eb 07                	jmp    80108556 <loaduvm+0x87>
    else
      n = PGSIZE;
8010854f:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108556:	8b 55 14             	mov    0x14(%ebp),%edx
80108559:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010855f:	83 ec 0c             	sub    $0xc,%esp
80108562:	ff 75 e8             	pushl  -0x18(%ebp)
80108565:	e8 e3 f6 ff ff       	call   80107c4d <p2v>
8010856a:	83 c4 10             	add    $0x10,%esp
8010856d:	ff 75 f0             	pushl  -0x10(%ebp)
80108570:	53                   	push   %ebx
80108571:	50                   	push   %eax
80108572:	ff 75 10             	pushl  0x10(%ebp)
80108575:	e8 5e 99 ff ff       	call   80101ed8 <readi>
8010857a:	83 c4 10             	add    $0x10,%esp
8010857d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108580:	74 07                	je     80108589 <loaduvm+0xba>
      return -1;
80108582:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108587:	eb 18                	jmp    801085a1 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108589:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108593:	3b 45 18             	cmp    0x18(%ebp),%eax
80108596:	0f 82 5f ff ff ff    	jb     801084fb <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010859c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801085a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085a4:	c9                   	leave  
801085a5:	c3                   	ret    

801085a6 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801085a6:	55                   	push   %ebp
801085a7:	89 e5                	mov    %esp,%ebp
801085a9:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801085ac:	8b 45 10             	mov    0x10(%ebp),%eax
801085af:	85 c0                	test   %eax,%eax
801085b1:	79 0a                	jns    801085bd <allocuvm+0x17>
    return 0;
801085b3:	b8 00 00 00 00       	mov    $0x0,%eax
801085b8:	e9 b0 00 00 00       	jmp    8010866d <allocuvm+0xc7>
  if(newsz < oldsz)
801085bd:	8b 45 10             	mov    0x10(%ebp),%eax
801085c0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801085c3:	73 08                	jae    801085cd <allocuvm+0x27>
    return oldsz;
801085c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801085c8:	e9 a0 00 00 00       	jmp    8010866d <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
801085cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801085d0:	05 ff 0f 00 00       	add    $0xfff,%eax
801085d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801085dd:	eb 7f                	jmp    8010865e <allocuvm+0xb8>
    mem = kalloc();
801085df:	e8 82 a6 ff ff       	call   80102c66 <kalloc>
801085e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801085e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085eb:	75 2b                	jne    80108618 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
801085ed:	83 ec 0c             	sub    $0xc,%esp
801085f0:	68 f9 90 10 80       	push   $0x801090f9
801085f5:	e8 cc 7d ff ff       	call   801003c6 <cprintf>
801085fa:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801085fd:	83 ec 04             	sub    $0x4,%esp
80108600:	ff 75 0c             	pushl  0xc(%ebp)
80108603:	ff 75 10             	pushl  0x10(%ebp)
80108606:	ff 75 08             	pushl  0x8(%ebp)
80108609:	e8 61 00 00 00       	call   8010866f <deallocuvm>
8010860e:	83 c4 10             	add    $0x10,%esp
      return 0;
80108611:	b8 00 00 00 00       	mov    $0x0,%eax
80108616:	eb 55                	jmp    8010866d <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108618:	83 ec 04             	sub    $0x4,%esp
8010861b:	68 00 10 00 00       	push   $0x1000
80108620:	6a 00                	push   $0x0
80108622:	ff 75 f0             	pushl  -0x10(%ebp)
80108625:	e8 d7 cf ff ff       	call   80105601 <memset>
8010862a:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
8010862d:	83 ec 0c             	sub    $0xc,%esp
80108630:	ff 75 f0             	pushl  -0x10(%ebp)
80108633:	e8 08 f6 ff ff       	call   80107c40 <v2p>
80108638:	83 c4 10             	add    $0x10,%esp
8010863b:	89 c2                	mov    %eax,%edx
8010863d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108640:	83 ec 0c             	sub    $0xc,%esp
80108643:	6a 06                	push   $0x6
80108645:	52                   	push   %edx
80108646:	68 00 10 00 00       	push   $0x1000
8010864b:	50                   	push   %eax
8010864c:	ff 75 08             	pushl  0x8(%ebp)
8010864f:	e8 1b fb ff ff       	call   8010816f <mappages>
80108654:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108657:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010865e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108661:	3b 45 10             	cmp    0x10(%ebp),%eax
80108664:	0f 82 75 ff ff ff    	jb     801085df <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
8010866a:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010866d:	c9                   	leave  
8010866e:	c3                   	ret    

8010866f <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010866f:	55                   	push   %ebp
80108670:	89 e5                	mov    %esp,%ebp
80108672:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108675:	8b 45 10             	mov    0x10(%ebp),%eax
80108678:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010867b:	72 08                	jb     80108685 <deallocuvm+0x16>
    return oldsz;
8010867d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108680:	e9 a5 00 00 00       	jmp    8010872a <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108685:	8b 45 10             	mov    0x10(%ebp),%eax
80108688:	05 ff 0f 00 00       	add    $0xfff,%eax
8010868d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108692:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108695:	e9 81 00 00 00       	jmp    8010871b <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869d:	83 ec 04             	sub    $0x4,%esp
801086a0:	6a 00                	push   $0x0
801086a2:	50                   	push   %eax
801086a3:	ff 75 08             	pushl  0x8(%ebp)
801086a6:	e8 24 fa ff ff       	call   801080cf <walkpgdir>
801086ab:	83 c4 10             	add    $0x10,%esp
801086ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801086b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086b5:	75 09                	jne    801086c0 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
801086b7:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
801086be:	eb 54                	jmp    80108714 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
801086c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086c3:	8b 00                	mov    (%eax),%eax
801086c5:	83 e0 01             	and    $0x1,%eax
801086c8:	85 c0                	test   %eax,%eax
801086ca:	74 48                	je     80108714 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
801086cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086cf:	8b 00                	mov    (%eax),%eax
801086d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
801086d9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086dd:	75 0d                	jne    801086ec <deallocuvm+0x7d>
        panic("kfree");
801086df:	83 ec 0c             	sub    $0xc,%esp
801086e2:	68 11 91 10 80       	push   $0x80109111
801086e7:	e8 7a 7e ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
801086ec:	83 ec 0c             	sub    $0xc,%esp
801086ef:	ff 75 ec             	pushl  -0x14(%ebp)
801086f2:	e8 56 f5 ff ff       	call   80107c4d <p2v>
801086f7:	83 c4 10             	add    $0x10,%esp
801086fa:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
801086fd:	83 ec 0c             	sub    $0xc,%esp
80108700:	ff 75 e8             	pushl  -0x18(%ebp)
80108703:	e8 c1 a4 ff ff       	call   80102bc9 <kfree>
80108708:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010870b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010870e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108714:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010871b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108721:	0f 82 73 ff ff ff    	jb     8010869a <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108727:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010872a:	c9                   	leave  
8010872b:	c3                   	ret    

8010872c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010872c:	55                   	push   %ebp
8010872d:	89 e5                	mov    %esp,%ebp
8010872f:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108732:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108736:	75 0d                	jne    80108745 <freevm+0x19>
    panic("freevm: no pgdir");
80108738:	83 ec 0c             	sub    $0xc,%esp
8010873b:	68 17 91 10 80       	push   $0x80109117
80108740:	e8 21 7e ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108745:	83 ec 04             	sub    $0x4,%esp
80108748:	6a 00                	push   $0x0
8010874a:	68 00 00 00 80       	push   $0x80000000
8010874f:	ff 75 08             	pushl  0x8(%ebp)
80108752:	e8 18 ff ff ff       	call   8010866f <deallocuvm>
80108757:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
8010875a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108761:	eb 4f                	jmp    801087b2 <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108763:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108766:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010876d:	8b 45 08             	mov    0x8(%ebp),%eax
80108770:	01 d0                	add    %edx,%eax
80108772:	8b 00                	mov    (%eax),%eax
80108774:	83 e0 01             	and    $0x1,%eax
80108777:	85 c0                	test   %eax,%eax
80108779:	74 33                	je     801087ae <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
8010877b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108785:	8b 45 08             	mov    0x8(%ebp),%eax
80108788:	01 d0                	add    %edx,%eax
8010878a:	8b 00                	mov    (%eax),%eax
8010878c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108791:	83 ec 0c             	sub    $0xc,%esp
80108794:	50                   	push   %eax
80108795:	e8 b3 f4 ff ff       	call   80107c4d <p2v>
8010879a:	83 c4 10             	add    $0x10,%esp
8010879d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801087a0:	83 ec 0c             	sub    $0xc,%esp
801087a3:	ff 75 f0             	pushl  -0x10(%ebp)
801087a6:	e8 1e a4 ff ff       	call   80102bc9 <kfree>
801087ab:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801087ae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801087b2:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801087b9:	76 a8                	jbe    80108763 <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801087bb:	83 ec 0c             	sub    $0xc,%esp
801087be:	ff 75 08             	pushl  0x8(%ebp)
801087c1:	e8 03 a4 ff ff       	call   80102bc9 <kfree>
801087c6:	83 c4 10             	add    $0x10,%esp
}
801087c9:	90                   	nop
801087ca:	c9                   	leave  
801087cb:	c3                   	ret    

801087cc <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801087cc:	55                   	push   %ebp
801087cd:	89 e5                	mov    %esp,%ebp
801087cf:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801087d2:	83 ec 04             	sub    $0x4,%esp
801087d5:	6a 00                	push   $0x0
801087d7:	ff 75 0c             	pushl  0xc(%ebp)
801087da:	ff 75 08             	pushl  0x8(%ebp)
801087dd:	e8 ed f8 ff ff       	call   801080cf <walkpgdir>
801087e2:	83 c4 10             	add    $0x10,%esp
801087e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
801087e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087ec:	75 0d                	jne    801087fb <clearpteu+0x2f>
    panic("clearpteu");
801087ee:	83 ec 0c             	sub    $0xc,%esp
801087f1:	68 28 91 10 80       	push   $0x80109128
801087f6:	e8 6b 7d ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
801087fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fe:	8b 00                	mov    (%eax),%eax
80108800:	83 e0 fb             	and    $0xfffffffb,%eax
80108803:	89 c2                	mov    %eax,%edx
80108805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108808:	89 10                	mov    %edx,(%eax)
}
8010880a:	90                   	nop
8010880b:	c9                   	leave  
8010880c:	c3                   	ret    

8010880d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010880d:	55                   	push   %ebp
8010880e:	89 e5                	mov    %esp,%ebp
80108810:	53                   	push   %ebx
80108811:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108814:	e8 e6 f9 ff ff       	call   801081ff <setupkvm>
80108819:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010881c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108820:	75 0a                	jne    8010882c <copyuvm+0x1f>
    return 0;
80108822:	b8 00 00 00 00       	mov    $0x0,%eax
80108827:	e9 f8 00 00 00       	jmp    80108924 <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
8010882c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108833:	e9 c4 00 00 00       	jmp    801088fc <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108838:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010883b:	83 ec 04             	sub    $0x4,%esp
8010883e:	6a 00                	push   $0x0
80108840:	50                   	push   %eax
80108841:	ff 75 08             	pushl  0x8(%ebp)
80108844:	e8 86 f8 ff ff       	call   801080cf <walkpgdir>
80108849:	83 c4 10             	add    $0x10,%esp
8010884c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010884f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108853:	75 0d                	jne    80108862 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108855:	83 ec 0c             	sub    $0xc,%esp
80108858:	68 32 91 10 80       	push   $0x80109132
8010885d:	e8 04 7d ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108862:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108865:	8b 00                	mov    (%eax),%eax
80108867:	83 e0 01             	and    $0x1,%eax
8010886a:	85 c0                	test   %eax,%eax
8010886c:	75 0d                	jne    8010887b <copyuvm+0x6e>
      panic("copyuvm: page not present");
8010886e:	83 ec 0c             	sub    $0xc,%esp
80108871:	68 4c 91 10 80       	push   $0x8010914c
80108876:	e8 eb 7c ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
8010887b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010887e:	8b 00                	mov    (%eax),%eax
80108880:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108885:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108888:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010888b:	8b 00                	mov    (%eax),%eax
8010888d:	25 ff 0f 00 00       	and    $0xfff,%eax
80108892:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108895:	e8 cc a3 ff ff       	call   80102c66 <kalloc>
8010889a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010889d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801088a1:	74 6a                	je     8010890d <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801088a3:	83 ec 0c             	sub    $0xc,%esp
801088a6:	ff 75 e8             	pushl  -0x18(%ebp)
801088a9:	e8 9f f3 ff ff       	call   80107c4d <p2v>
801088ae:	83 c4 10             	add    $0x10,%esp
801088b1:	83 ec 04             	sub    $0x4,%esp
801088b4:	68 00 10 00 00       	push   $0x1000
801088b9:	50                   	push   %eax
801088ba:	ff 75 e0             	pushl  -0x20(%ebp)
801088bd:	e8 fe cd ff ff       	call   801056c0 <memmove>
801088c2:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
801088c5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801088c8:	83 ec 0c             	sub    $0xc,%esp
801088cb:	ff 75 e0             	pushl  -0x20(%ebp)
801088ce:	e8 6d f3 ff ff       	call   80107c40 <v2p>
801088d3:	83 c4 10             	add    $0x10,%esp
801088d6:	89 c2                	mov    %eax,%edx
801088d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088db:	83 ec 0c             	sub    $0xc,%esp
801088de:	53                   	push   %ebx
801088df:	52                   	push   %edx
801088e0:	68 00 10 00 00       	push   $0x1000
801088e5:	50                   	push   %eax
801088e6:	ff 75 f0             	pushl  -0x10(%ebp)
801088e9:	e8 81 f8 ff ff       	call   8010816f <mappages>
801088ee:	83 c4 20             	add    $0x20,%esp
801088f1:	85 c0                	test   %eax,%eax
801088f3:	78 1b                	js     80108910 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801088f5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ff:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108902:	0f 82 30 ff ff ff    	jb     80108838 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108908:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010890b:	eb 17                	jmp    80108924 <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
8010890d:	90                   	nop
8010890e:	eb 01                	jmp    80108911 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108910:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108911:	83 ec 0c             	sub    $0xc,%esp
80108914:	ff 75 f0             	pushl  -0x10(%ebp)
80108917:	e8 10 fe ff ff       	call   8010872c <freevm>
8010891c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010891f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108927:	c9                   	leave  
80108928:	c3                   	ret    

80108929 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108929:	55                   	push   %ebp
8010892a:	89 e5                	mov    %esp,%ebp
8010892c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010892f:	83 ec 04             	sub    $0x4,%esp
80108932:	6a 00                	push   $0x0
80108934:	ff 75 0c             	pushl  0xc(%ebp)
80108937:	ff 75 08             	pushl  0x8(%ebp)
8010893a:	e8 90 f7 ff ff       	call   801080cf <walkpgdir>
8010893f:	83 c4 10             	add    $0x10,%esp
80108942:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108948:	8b 00                	mov    (%eax),%eax
8010894a:	83 e0 01             	and    $0x1,%eax
8010894d:	85 c0                	test   %eax,%eax
8010894f:	75 07                	jne    80108958 <uva2ka+0x2f>
    return 0;
80108951:	b8 00 00 00 00       	mov    $0x0,%eax
80108956:	eb 29                	jmp    80108981 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895b:	8b 00                	mov    (%eax),%eax
8010895d:	83 e0 04             	and    $0x4,%eax
80108960:	85 c0                	test   %eax,%eax
80108962:	75 07                	jne    8010896b <uva2ka+0x42>
    return 0;
80108964:	b8 00 00 00 00       	mov    $0x0,%eax
80108969:	eb 16                	jmp    80108981 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
8010896b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010896e:	8b 00                	mov    (%eax),%eax
80108970:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108975:	83 ec 0c             	sub    $0xc,%esp
80108978:	50                   	push   %eax
80108979:	e8 cf f2 ff ff       	call   80107c4d <p2v>
8010897e:	83 c4 10             	add    $0x10,%esp
}
80108981:	c9                   	leave  
80108982:	c3                   	ret    

80108983 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108983:	55                   	push   %ebp
80108984:	89 e5                	mov    %esp,%ebp
80108986:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108989:	8b 45 10             	mov    0x10(%ebp),%eax
8010898c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010898f:	eb 7f                	jmp    80108a10 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108991:	8b 45 0c             	mov    0xc(%ebp),%eax
80108994:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108999:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
8010899c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010899f:	83 ec 08             	sub    $0x8,%esp
801089a2:	50                   	push   %eax
801089a3:	ff 75 08             	pushl  0x8(%ebp)
801089a6:	e8 7e ff ff ff       	call   80108929 <uva2ka>
801089ab:	83 c4 10             	add    $0x10,%esp
801089ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801089b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801089b5:	75 07                	jne    801089be <copyout+0x3b>
      return -1;
801089b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089bc:	eb 61                	jmp    80108a1f <copyout+0x9c>
    n = PGSIZE - (va - va0);
801089be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089c1:	2b 45 0c             	sub    0xc(%ebp),%eax
801089c4:	05 00 10 00 00       	add    $0x1000,%eax
801089c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801089cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089cf:	3b 45 14             	cmp    0x14(%ebp),%eax
801089d2:	76 06                	jbe    801089da <copyout+0x57>
      n = len;
801089d4:	8b 45 14             	mov    0x14(%ebp),%eax
801089d7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801089da:	8b 45 0c             	mov    0xc(%ebp),%eax
801089dd:	2b 45 ec             	sub    -0x14(%ebp),%eax
801089e0:	89 c2                	mov    %eax,%edx
801089e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801089e5:	01 d0                	add    %edx,%eax
801089e7:	83 ec 04             	sub    $0x4,%esp
801089ea:	ff 75 f0             	pushl  -0x10(%ebp)
801089ed:	ff 75 f4             	pushl  -0xc(%ebp)
801089f0:	50                   	push   %eax
801089f1:	e8 ca cc ff ff       	call   801056c0 <memmove>
801089f6:	83 c4 10             	add    $0x10,%esp
    len -= n;
801089f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089fc:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801089ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a02:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108a05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a08:	05 00 10 00 00       	add    $0x1000,%eax
80108a0d:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108a10:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108a14:	0f 85 77 ff ff ff    	jne    80108991 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a1f:	c9                   	leave  
80108a20:	c3                   	ret    
