
_ps:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

#define UPROCS_MAX 64 // 1 16 64 72

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	56                   	push   %esi
   e:	53                   	push   %ebx
   f:	51                   	push   %ecx
  10:	83 ec 2c             	sub    $0x2c,%esp
  int millisec, num_uprocs,  max = UPROCS_MAX;
  13:	c7 45 e0 40 00 00 00 	movl   $0x40,-0x20(%ebp)
  struct uproc* table = malloc(sizeof(struct uproc) * max);
  1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1d:	6b c0 5c             	imul   $0x5c,%eax,%eax
  20:	83 ec 0c             	sub    $0xc,%esp
  23:	50                   	push   %eax
  24:	e8 f2 09 00 00       	call   a1b <malloc>
  29:	83 c4 10             	add    $0x10,%esp
  2c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  struct uproc *begin, *end;

  if (!table) {
  2f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  33:	75 17                	jne    4c <main+0x4c>
    printf(2, "malloc failed in ps.c\n\n");
  35:	83 ec 08             	sub    $0x8,%esp
  38:	68 00 0b 00 00       	push   $0xb00
  3d:	6a 02                	push   $0x2
  3f:	e8 04 07 00 00       	call   748 <printf>
  44:	83 c4 10             	add    $0x10,%esp
    exit();
  47:	e8 45 05 00 00       	call   591 <exit>
  }
  
  num_uprocs = getprocs(max, table);
  4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  4f:	83 ec 08             	sub    $0x8,%esp
  52:	ff 75 dc             	pushl  -0x24(%ebp)
  55:	50                   	push   %eax
  56:	e8 0e 06 00 00       	call   669 <getprocs>
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  if (num_uprocs < 0) {
  61:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  65:	79 25                	jns    8c <main+0x8c>
    printf(2,"Error retrieving info for processes.\n");
  67:	83 ec 08             	sub    $0x8,%esp
  6a:	68 18 0b 00 00       	push   $0xb18
  6f:	6a 02                	push   $0x2
  71:	e8 d2 06 00 00       	call   748 <printf>
  76:	83 c4 10             	add    $0x10,%esp
    free(table);
  79:	83 ec 0c             	sub    $0xc,%esp
  7c:	ff 75 dc             	pushl  -0x24(%ebp)
  7f:	e8 55 08 00 00       	call   8d9 <free>
  84:	83 c4 10             	add    $0x10,%esp
    exit();
  87:	e8 05 05 00 00       	call   591 <exit>
  }
  
  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n");
  8c:	83 ec 08             	sub    $0x8,%esp
  8f:	68 40 0b 00 00       	push   $0xb40
  94:	6a 01                	push   $0x1
  96:	e8 ad 06 00 00       	call   748 <printf>
  9b:	83 c4 10             	add    $0x10,%esp

  begin = table;
  9e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  end = table + num_uprocs;
  a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  a7:	6b d0 5c             	imul   $0x5c,%eax,%edx
  aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  ad:	01 d0                	add    %edx,%eax
  af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  while (begin < end) {
  b2:	e9 91 01 00 00       	jmp    248 <main+0x248>
    printf(1,"%d\t%s\t%d\t%d\t%d\t", begin->pid,
  b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ba:	8b 58 0c             	mov    0xc(%eax),%ebx
  bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c0:	8b 48 08             	mov    0x8(%eax),%ecx
  c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  c6:	8b 50 04             	mov    0x4(%eax),%edx
         begin->name,begin->uid,begin->gid,begin->ppid);
  c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  cc:	8d 70 3c             	lea    0x3c(%eax),%esi
  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n");

  begin = table;
  end = table + num_uprocs;
  while (begin < end) {
    printf(1,"%d\t%s\t%d\t%d\t%d\t", begin->pid,
  cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  d2:	8b 00                	mov    (%eax),%eax
  d4:	83 ec 04             	sub    $0x4,%esp
  d7:	53                   	push   %ebx
  d8:	51                   	push   %ecx
  d9:	52                   	push   %edx
  da:	56                   	push   %esi
  db:	50                   	push   %eax
  dc:	68 6e 0b 00 00       	push   $0xb6e
  e1:	6a 01                	push   $0x1
  e3:	e8 60 06 00 00       	call   748 <printf>
  e8:	83 c4 20             	add    $0x20,%esp
         begin->name,begin->uid,begin->gid,begin->ppid);
//    print_millisec(begin->elapsed_ticks);
    millisec = begin->elapsed_ticks;
  eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ee:	8b 40 10             	mov    0x10(%eax),%eax
  f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    printf(1,"%d.", millisec /1000);
  f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  f7:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  fc:	89 c8                	mov    %ecx,%eax
  fe:	f7 ea                	imul   %edx
 100:	c1 fa 06             	sar    $0x6,%edx
 103:	89 c8                	mov    %ecx,%eax
 105:	c1 f8 1f             	sar    $0x1f,%eax
 108:	29 c2                	sub    %eax,%edx
 10a:	89 d0                	mov    %edx,%eax
 10c:	83 ec 04             	sub    $0x4,%esp
 10f:	50                   	push   %eax
 110:	68 7e 0b 00 00       	push   $0xb7e
 115:	6a 01                	push   $0x1
 117:	e8 2c 06 00 00       	call   748 <printf>
 11c:	83 c4 10             	add    $0x10,%esp

    millisec %= 1000;
 11f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 122:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 127:	89 c8                	mov    %ecx,%eax
 129:	f7 ea                	imul   %edx
 12b:	c1 fa 06             	sar    $0x6,%edx
 12e:	89 c8                	mov    %ecx,%eax
 130:	c1 f8 1f             	sar    $0x1f,%eax
 133:	29 c2                	sub    %eax,%edx
 135:	89 d0                	mov    %edx,%eax
 137:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 13d:	29 c1                	sub    %eax,%ecx
 13f:	89 c8                	mov    %ecx,%eax
 141:	89 45 d0             	mov    %eax,-0x30(%ebp)
    if (millisec < 100)
 144:	83 7d d0 63          	cmpl   $0x63,-0x30(%ebp)
 148:	7f 12                	jg     15c <main+0x15c>
      printf(1,"0");
 14a:	83 ec 08             	sub    $0x8,%esp
 14d:	68 82 0b 00 00       	push   $0xb82
 152:	6a 01                	push   $0x1
 154:	e8 ef 05 00 00       	call   748 <printf>
 159:	83 c4 10             	add    $0x10,%esp
    if (millisec < 10)
 15c:	83 7d d0 09          	cmpl   $0x9,-0x30(%ebp)
 160:	7f 12                	jg     174 <main+0x174>
      printf(1,"0");
 162:	83 ec 08             	sub    $0x8,%esp
 165:	68 82 0b 00 00       	push   $0xb82
 16a:	6a 01                	push   $0x1
 16c:	e8 d7 05 00 00       	call   748 <printf>
 171:	83 c4 10             	add    $0x10,%esp

    printf(1,"%d\t", millisec);
 174:	83 ec 04             	sub    $0x4,%esp
 177:	ff 75 d0             	pushl  -0x30(%ebp)
 17a:	68 84 0b 00 00       	push   $0xb84
 17f:	6a 01                	push   $0x1
 181:	e8 c2 05 00 00       	call   748 <printf>
 186:	83 c4 10             	add    $0x10,%esp
    millisec = begin->CPU_total_ticks;
 189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 18c:	8b 40 14             	mov    0x14(%eax),%eax
 18f:	89 45 d0             	mov    %eax,-0x30(%ebp)
    printf(1,"%d.", millisec /1000);
 192:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 195:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 19a:	89 c8                	mov    %ecx,%eax
 19c:	f7 ea                	imul   %edx
 19e:	c1 fa 06             	sar    $0x6,%edx
 1a1:	89 c8                	mov    %ecx,%eax
 1a3:	c1 f8 1f             	sar    $0x1f,%eax
 1a6:	29 c2                	sub    %eax,%edx
 1a8:	89 d0                	mov    %edx,%eax
 1aa:	83 ec 04             	sub    $0x4,%esp
 1ad:	50                   	push   %eax
 1ae:	68 7e 0b 00 00       	push   $0xb7e
 1b3:	6a 01                	push   $0x1
 1b5:	e8 8e 05 00 00       	call   748 <printf>
 1ba:	83 c4 10             	add    $0x10,%esp

    millisec %= 1000;
 1bd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
 1c0:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
 1c5:	89 c8                	mov    %ecx,%eax
 1c7:	f7 ea                	imul   %edx
 1c9:	c1 fa 06             	sar    $0x6,%edx
 1cc:	89 c8                	mov    %ecx,%eax
 1ce:	c1 f8 1f             	sar    $0x1f,%eax
 1d1:	29 c2                	sub    %eax,%edx
 1d3:	89 d0                	mov    %edx,%eax
 1d5:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
 1db:	29 c1                	sub    %eax,%ecx
 1dd:	89 c8                	mov    %ecx,%eax
 1df:	89 45 d0             	mov    %eax,-0x30(%ebp)
    if (millisec < 100)
 1e2:	83 7d d0 63          	cmpl   $0x63,-0x30(%ebp)
 1e6:	7f 12                	jg     1fa <main+0x1fa>
      printf(1,"0");
 1e8:	83 ec 08             	sub    $0x8,%esp
 1eb:	68 82 0b 00 00       	push   $0xb82
 1f0:	6a 01                	push   $0x1
 1f2:	e8 51 05 00 00       	call   748 <printf>
 1f7:	83 c4 10             	add    $0x10,%esp
    if (millisec < 10)
 1fa:	83 7d d0 09          	cmpl   $0x9,-0x30(%ebp)
 1fe:	7f 12                	jg     212 <main+0x212>
      printf(1,"0");
 200:	83 ec 08             	sub    $0x8,%esp
 203:	68 82 0b 00 00       	push   $0xb82
 208:	6a 01                	push   $0x1
 20a:	e8 39 05 00 00       	call   748 <printf>
 20f:	83 c4 10             	add    $0x10,%esp

    printf(1,"%d\t", millisec);
 212:	83 ec 04             	sub    $0x4,%esp
 215:	ff 75 d0             	pushl  -0x30(%ebp)
 218:	68 84 0b 00 00       	push   $0xb84
 21d:	6a 01                	push   $0x1
 21f:	e8 24 05 00 00       	call   748 <printf>
 224:	83 c4 10             	add    $0x10,%esp
    printf(1,"%s\t%d\n",begin->state,begin->size);
 227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 22a:	8b 40 38             	mov    0x38(%eax),%eax
 22d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 230:	83 c2 18             	add    $0x18,%edx
 233:	50                   	push   %eax
 234:	52                   	push   %edx
 235:	68 88 0b 00 00       	push   $0xb88
 23a:	6a 01                	push   $0x1
 23c:	e8 07 05 00 00       	call   748 <printf>
 241:	83 c4 10             	add    $0x10,%esp

    ++begin;
 244:	83 45 e4 5c          	addl   $0x5c,-0x1c(%ebp)
  
  printf(1,"PID\tName\tUID\tGID\tPPID\tElapsed\tCPU\tState\tSize\n");

  begin = table;
  end = table + num_uprocs;
  while (begin < end) {
 248:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 24b:	3b 45 d4             	cmp    -0x2c(%ebp),%eax
 24e:	0f 82 63 fe ff ff    	jb     b7 <main+0xb7>
    printf(1,"%s\t%d\n",begin->state,begin->size);

    ++begin;
  }

  free(table);
 254:	83 ec 0c             	sub    $0xc,%esp
 257:	ff 75 dc             	pushl  -0x24(%ebp)
 25a:	e8 7a 06 00 00       	call   8d9 <free>
 25f:	83 c4 10             	add    $0x10,%esp
  exit();
 262:	e8 2a 03 00 00       	call   591 <exit>

00000267 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 267:	55                   	push   %ebp
 268:	89 e5                	mov    %esp,%ebp
 26a:	57                   	push   %edi
 26b:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 26c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 26f:	8b 55 10             	mov    0x10(%ebp),%edx
 272:	8b 45 0c             	mov    0xc(%ebp),%eax
 275:	89 cb                	mov    %ecx,%ebx
 277:	89 df                	mov    %ebx,%edi
 279:	89 d1                	mov    %edx,%ecx
 27b:	fc                   	cld    
 27c:	f3 aa                	rep stos %al,%es:(%edi)
 27e:	89 ca                	mov    %ecx,%edx
 280:	89 fb                	mov    %edi,%ebx
 282:	89 5d 08             	mov    %ebx,0x8(%ebp)
 285:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 288:	90                   	nop
 289:	5b                   	pop    %ebx
 28a:	5f                   	pop    %edi
 28b:	5d                   	pop    %ebp
 28c:	c3                   	ret    

0000028d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 28d:	55                   	push   %ebp
 28e:	89 e5                	mov    %esp,%ebp
 290:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 299:	90                   	nop
 29a:	8b 45 08             	mov    0x8(%ebp),%eax
 29d:	8d 50 01             	lea    0x1(%eax),%edx
 2a0:	89 55 08             	mov    %edx,0x8(%ebp)
 2a3:	8b 55 0c             	mov    0xc(%ebp),%edx
 2a6:	8d 4a 01             	lea    0x1(%edx),%ecx
 2a9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2ac:	0f b6 12             	movzbl (%edx),%edx
 2af:	88 10                	mov    %dl,(%eax)
 2b1:	0f b6 00             	movzbl (%eax),%eax
 2b4:	84 c0                	test   %al,%al
 2b6:	75 e2                	jne    29a <strcpy+0xd>
    ;
  return os;
 2b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2bb:	c9                   	leave  
 2bc:	c3                   	ret    

000002bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2bd:	55                   	push   %ebp
 2be:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2c0:	eb 08                	jmp    2ca <strcmp+0xd>
    p++, q++;
 2c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2ca:	8b 45 08             	mov    0x8(%ebp),%eax
 2cd:	0f b6 00             	movzbl (%eax),%eax
 2d0:	84 c0                	test   %al,%al
 2d2:	74 10                	je     2e4 <strcmp+0x27>
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	0f b6 10             	movzbl (%eax),%edx
 2da:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dd:	0f b6 00             	movzbl (%eax),%eax
 2e0:	38 c2                	cmp    %al,%dl
 2e2:	74 de                	je     2c2 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	0f b6 00             	movzbl (%eax),%eax
 2ea:	0f b6 d0             	movzbl %al,%edx
 2ed:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f0:	0f b6 00             	movzbl (%eax),%eax
 2f3:	0f b6 c0             	movzbl %al,%eax
 2f6:	29 c2                	sub    %eax,%edx
 2f8:	89 d0                	mov    %edx,%eax
}
 2fa:	5d                   	pop    %ebp
 2fb:	c3                   	ret    

000002fc <strlen>:

uint
strlen(char *s)
{
 2fc:	55                   	push   %ebp
 2fd:	89 e5                	mov    %esp,%ebp
 2ff:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 302:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 309:	eb 04                	jmp    30f <strlen+0x13>
 30b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 30f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 312:	8b 45 08             	mov    0x8(%ebp),%eax
 315:	01 d0                	add    %edx,%eax
 317:	0f b6 00             	movzbl (%eax),%eax
 31a:	84 c0                	test   %al,%al
 31c:	75 ed                	jne    30b <strlen+0xf>
    ;
  return n;
 31e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 321:	c9                   	leave  
 322:	c3                   	ret    

00000323 <memset>:

void*
memset(void *dst, int c, uint n)
{
 323:	55                   	push   %ebp
 324:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 326:	8b 45 10             	mov    0x10(%ebp),%eax
 329:	50                   	push   %eax
 32a:	ff 75 0c             	pushl  0xc(%ebp)
 32d:	ff 75 08             	pushl  0x8(%ebp)
 330:	e8 32 ff ff ff       	call   267 <stosb>
 335:	83 c4 0c             	add    $0xc,%esp
  return dst;
 338:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33b:	c9                   	leave  
 33c:	c3                   	ret    

0000033d <strchr>:

char*
strchr(const char *s, char c)
{
 33d:	55                   	push   %ebp
 33e:	89 e5                	mov    %esp,%ebp
 340:	83 ec 04             	sub    $0x4,%esp
 343:	8b 45 0c             	mov    0xc(%ebp),%eax
 346:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 349:	eb 14                	jmp    35f <strchr+0x22>
    if(*s == c)
 34b:	8b 45 08             	mov    0x8(%ebp),%eax
 34e:	0f b6 00             	movzbl (%eax),%eax
 351:	3a 45 fc             	cmp    -0x4(%ebp),%al
 354:	75 05                	jne    35b <strchr+0x1e>
      return (char*)s;
 356:	8b 45 08             	mov    0x8(%ebp),%eax
 359:	eb 13                	jmp    36e <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 35b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 35f:	8b 45 08             	mov    0x8(%ebp),%eax
 362:	0f b6 00             	movzbl (%eax),%eax
 365:	84 c0                	test   %al,%al
 367:	75 e2                	jne    34b <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 369:	b8 00 00 00 00       	mov    $0x0,%eax
}
 36e:	c9                   	leave  
 36f:	c3                   	ret    

00000370 <gets>:

char*
gets(char *buf, int max)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 37d:	eb 42                	jmp    3c1 <gets+0x51>
    cc = read(0, &c, 1);
 37f:	83 ec 04             	sub    $0x4,%esp
 382:	6a 01                	push   $0x1
 384:	8d 45 ef             	lea    -0x11(%ebp),%eax
 387:	50                   	push   %eax
 388:	6a 00                	push   $0x0
 38a:	e8 1a 02 00 00       	call   5a9 <read>
 38f:	83 c4 10             	add    $0x10,%esp
 392:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 395:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 399:	7e 33                	jle    3ce <gets+0x5e>
      break;
    buf[i++] = c;
 39b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39e:	8d 50 01             	lea    0x1(%eax),%edx
 3a1:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3a4:	89 c2                	mov    %eax,%edx
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	01 c2                	add    %eax,%edx
 3ab:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3af:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3b1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3b5:	3c 0a                	cmp    $0xa,%al
 3b7:	74 16                	je     3cf <gets+0x5f>
 3b9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3bd:	3c 0d                	cmp    $0xd,%al
 3bf:	74 0e                	je     3cf <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c4:	83 c0 01             	add    $0x1,%eax
 3c7:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3ca:	7c b3                	jl     37f <gets+0xf>
 3cc:	eb 01                	jmp    3cf <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3ce:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3d2:	8b 45 08             	mov    0x8(%ebp),%eax
 3d5:	01 d0                	add    %edx,%eax
 3d7:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3da:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3dd:	c9                   	leave  
 3de:	c3                   	ret    

000003df <stat>:

int
stat(char *n, struct stat *st)
{
 3df:	55                   	push   %ebp
 3e0:	89 e5                	mov    %esp,%ebp
 3e2:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3e5:	83 ec 08             	sub    $0x8,%esp
 3e8:	6a 00                	push   $0x0
 3ea:	ff 75 08             	pushl  0x8(%ebp)
 3ed:	e8 df 01 00 00       	call   5d1 <open>
 3f2:	83 c4 10             	add    $0x10,%esp
 3f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3fc:	79 07                	jns    405 <stat+0x26>
    return -1;
 3fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 403:	eb 25                	jmp    42a <stat+0x4b>
  r = fstat(fd, st);
 405:	83 ec 08             	sub    $0x8,%esp
 408:	ff 75 0c             	pushl  0xc(%ebp)
 40b:	ff 75 f4             	pushl  -0xc(%ebp)
 40e:	e8 d6 01 00 00       	call   5e9 <fstat>
 413:	83 c4 10             	add    $0x10,%esp
 416:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 419:	83 ec 0c             	sub    $0xc,%esp
 41c:	ff 75 f4             	pushl  -0xc(%ebp)
 41f:	e8 95 01 00 00       	call   5b9 <close>
 424:	83 c4 10             	add    $0x10,%esp
  return r;
 427:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 42a:	c9                   	leave  
 42b:	c3                   	ret    

0000042c <atoi>:

int
atoi(const char *s)
{
 42c:	55                   	push   %ebp
 42d:	89 e5                	mov    %esp,%ebp
 42f:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 432:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 439:	eb 04                	jmp    43f <atoi+0x13>
 43b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 43f:	8b 45 08             	mov    0x8(%ebp),%eax
 442:	0f b6 00             	movzbl (%eax),%eax
 445:	3c 20                	cmp    $0x20,%al
 447:	74 f2                	je     43b <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 449:	8b 45 08             	mov    0x8(%ebp),%eax
 44c:	0f b6 00             	movzbl (%eax),%eax
 44f:	3c 2d                	cmp    $0x2d,%al
 451:	75 07                	jne    45a <atoi+0x2e>
 453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 458:	eb 05                	jmp    45f <atoi+0x33>
 45a:	b8 01 00 00 00       	mov    $0x1,%eax
 45f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 462:	8b 45 08             	mov    0x8(%ebp),%eax
 465:	0f b6 00             	movzbl (%eax),%eax
 468:	3c 2b                	cmp    $0x2b,%al
 46a:	74 0a                	je     476 <atoi+0x4a>
 46c:	8b 45 08             	mov    0x8(%ebp),%eax
 46f:	0f b6 00             	movzbl (%eax),%eax
 472:	3c 2d                	cmp    $0x2d,%al
 474:	75 2b                	jne    4a1 <atoi+0x75>
    s++;
 476:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 47a:	eb 25                	jmp    4a1 <atoi+0x75>
    n = n*10 + *s++ - '0';
 47c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 47f:	89 d0                	mov    %edx,%eax
 481:	c1 e0 02             	shl    $0x2,%eax
 484:	01 d0                	add    %edx,%eax
 486:	01 c0                	add    %eax,%eax
 488:	89 c1                	mov    %eax,%ecx
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	8d 50 01             	lea    0x1(%eax),%edx
 490:	89 55 08             	mov    %edx,0x8(%ebp)
 493:	0f b6 00             	movzbl (%eax),%eax
 496:	0f be c0             	movsbl %al,%eax
 499:	01 c8                	add    %ecx,%eax
 49b:	83 e8 30             	sub    $0x30,%eax
 49e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 4a1:	8b 45 08             	mov    0x8(%ebp),%eax
 4a4:	0f b6 00             	movzbl (%eax),%eax
 4a7:	3c 2f                	cmp    $0x2f,%al
 4a9:	7e 0a                	jle    4b5 <atoi+0x89>
 4ab:	8b 45 08             	mov    0x8(%ebp),%eax
 4ae:	0f b6 00             	movzbl (%eax),%eax
 4b1:	3c 39                	cmp    $0x39,%al
 4b3:	7e c7                	jle    47c <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 4b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4b8:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 4bc:	c9                   	leave  
 4bd:	c3                   	ret    

000004be <atoo>:

int
atoo(const char *s)
{
 4be:	55                   	push   %ebp
 4bf:	89 e5                	mov    %esp,%ebp
 4c1:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4cb:	eb 04                	jmp    4d1 <atoo+0x13>
 4cd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	0f b6 00             	movzbl (%eax),%eax
 4d7:	3c 20                	cmp    $0x20,%al
 4d9:	74 f2                	je     4cd <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
 4de:	0f b6 00             	movzbl (%eax),%eax
 4e1:	3c 2d                	cmp    $0x2d,%al
 4e3:	75 07                	jne    4ec <atoo+0x2e>
 4e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4ea:	eb 05                	jmp    4f1 <atoo+0x33>
 4ec:	b8 01 00 00 00       	mov    $0x1,%eax
 4f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 4f4:	8b 45 08             	mov    0x8(%ebp),%eax
 4f7:	0f b6 00             	movzbl (%eax),%eax
 4fa:	3c 2b                	cmp    $0x2b,%al
 4fc:	74 0a                	je     508 <atoo+0x4a>
 4fe:	8b 45 08             	mov    0x8(%ebp),%eax
 501:	0f b6 00             	movzbl (%eax),%eax
 504:	3c 2d                	cmp    $0x2d,%al
 506:	75 27                	jne    52f <atoo+0x71>
    s++;
 508:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 50c:	eb 21                	jmp    52f <atoo+0x71>
    n = n*8 + *s++ - '0';
 50e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 511:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 518:	8b 45 08             	mov    0x8(%ebp),%eax
 51b:	8d 50 01             	lea    0x1(%eax),%edx
 51e:	89 55 08             	mov    %edx,0x8(%ebp)
 521:	0f b6 00             	movzbl (%eax),%eax
 524:	0f be c0             	movsbl %al,%eax
 527:	01 c8                	add    %ecx,%eax
 529:	83 e8 30             	sub    $0x30,%eax
 52c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 52f:	8b 45 08             	mov    0x8(%ebp),%eax
 532:	0f b6 00             	movzbl (%eax),%eax
 535:	3c 2f                	cmp    $0x2f,%al
 537:	7e 0a                	jle    543 <atoo+0x85>
 539:	8b 45 08             	mov    0x8(%ebp),%eax
 53c:	0f b6 00             	movzbl (%eax),%eax
 53f:	3c 37                	cmp    $0x37,%al
 541:	7e cb                	jle    50e <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 543:	8b 45 f8             	mov    -0x8(%ebp),%eax
 546:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 54a:	c9                   	leave  
 54b:	c3                   	ret    

0000054c <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 54c:	55                   	push   %ebp
 54d:	89 e5                	mov    %esp,%ebp
 54f:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 552:	8b 45 08             	mov    0x8(%ebp),%eax
 555:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 558:	8b 45 0c             	mov    0xc(%ebp),%eax
 55b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 55e:	eb 17                	jmp    577 <memmove+0x2b>
    *dst++ = *src++;
 560:	8b 45 fc             	mov    -0x4(%ebp),%eax
 563:	8d 50 01             	lea    0x1(%eax),%edx
 566:	89 55 fc             	mov    %edx,-0x4(%ebp)
 569:	8b 55 f8             	mov    -0x8(%ebp),%edx
 56c:	8d 4a 01             	lea    0x1(%edx),%ecx
 56f:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 572:	0f b6 12             	movzbl (%edx),%edx
 575:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 577:	8b 45 10             	mov    0x10(%ebp),%eax
 57a:	8d 50 ff             	lea    -0x1(%eax),%edx
 57d:	89 55 10             	mov    %edx,0x10(%ebp)
 580:	85 c0                	test   %eax,%eax
 582:	7f dc                	jg     560 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 584:	8b 45 08             	mov    0x8(%ebp),%eax
}
 587:	c9                   	leave  
 588:	c3                   	ret    

00000589 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 589:	b8 01 00 00 00       	mov    $0x1,%eax
 58e:	cd 40                	int    $0x40
 590:	c3                   	ret    

00000591 <exit>:
SYSCALL(exit)
 591:	b8 02 00 00 00       	mov    $0x2,%eax
 596:	cd 40                	int    $0x40
 598:	c3                   	ret    

00000599 <wait>:
SYSCALL(wait)
 599:	b8 03 00 00 00       	mov    $0x3,%eax
 59e:	cd 40                	int    $0x40
 5a0:	c3                   	ret    

000005a1 <pipe>:
SYSCALL(pipe)
 5a1:	b8 04 00 00 00       	mov    $0x4,%eax
 5a6:	cd 40                	int    $0x40
 5a8:	c3                   	ret    

000005a9 <read>:
SYSCALL(read)
 5a9:	b8 05 00 00 00       	mov    $0x5,%eax
 5ae:	cd 40                	int    $0x40
 5b0:	c3                   	ret    

000005b1 <write>:
SYSCALL(write)
 5b1:	b8 10 00 00 00       	mov    $0x10,%eax
 5b6:	cd 40                	int    $0x40
 5b8:	c3                   	ret    

000005b9 <close>:
SYSCALL(close)
 5b9:	b8 15 00 00 00       	mov    $0x15,%eax
 5be:	cd 40                	int    $0x40
 5c0:	c3                   	ret    

000005c1 <kill>:
SYSCALL(kill)
 5c1:	b8 06 00 00 00       	mov    $0x6,%eax
 5c6:	cd 40                	int    $0x40
 5c8:	c3                   	ret    

000005c9 <exec>:
SYSCALL(exec)
 5c9:	b8 07 00 00 00       	mov    $0x7,%eax
 5ce:	cd 40                	int    $0x40
 5d0:	c3                   	ret    

000005d1 <open>:
SYSCALL(open)
 5d1:	b8 0f 00 00 00       	mov    $0xf,%eax
 5d6:	cd 40                	int    $0x40
 5d8:	c3                   	ret    

000005d9 <mknod>:
SYSCALL(mknod)
 5d9:	b8 11 00 00 00       	mov    $0x11,%eax
 5de:	cd 40                	int    $0x40
 5e0:	c3                   	ret    

000005e1 <unlink>:
SYSCALL(unlink)
 5e1:	b8 12 00 00 00       	mov    $0x12,%eax
 5e6:	cd 40                	int    $0x40
 5e8:	c3                   	ret    

000005e9 <fstat>:
SYSCALL(fstat)
 5e9:	b8 08 00 00 00       	mov    $0x8,%eax
 5ee:	cd 40                	int    $0x40
 5f0:	c3                   	ret    

000005f1 <link>:
SYSCALL(link)
 5f1:	b8 13 00 00 00       	mov    $0x13,%eax
 5f6:	cd 40                	int    $0x40
 5f8:	c3                   	ret    

000005f9 <mkdir>:
SYSCALL(mkdir)
 5f9:	b8 14 00 00 00       	mov    $0x14,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret    

00000601 <chdir>:
SYSCALL(chdir)
 601:	b8 09 00 00 00       	mov    $0x9,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret    

00000609 <dup>:
SYSCALL(dup)
 609:	b8 0a 00 00 00       	mov    $0xa,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret    

00000611 <getpid>:
SYSCALL(getpid)
 611:	b8 0b 00 00 00       	mov    $0xb,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret    

00000619 <sbrk>:
SYSCALL(sbrk)
 619:	b8 0c 00 00 00       	mov    $0xc,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret    

00000621 <sleep>:
SYSCALL(sleep)
 621:	b8 0d 00 00 00       	mov    $0xd,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret    

00000629 <uptime>:
SYSCALL(uptime)
 629:	b8 0e 00 00 00       	mov    $0xe,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret    

00000631 <halt>:
SYSCALL(halt)
 631:	b8 16 00 00 00       	mov    $0x16,%eax
 636:	cd 40                	int    $0x40
 638:	c3                   	ret    

00000639 <date>:
SYSCALL(date)
 639:	b8 17 00 00 00       	mov    $0x17,%eax
 63e:	cd 40                	int    $0x40
 640:	c3                   	ret    

00000641 <getuid>:
SYSCALL(getuid)
 641:	b8 18 00 00 00       	mov    $0x18,%eax
 646:	cd 40                	int    $0x40
 648:	c3                   	ret    

00000649 <getgid>:
SYSCALL(getgid)
 649:	b8 19 00 00 00       	mov    $0x19,%eax
 64e:	cd 40                	int    $0x40
 650:	c3                   	ret    

00000651 <getppid>:
SYSCALL(getppid)
 651:	b8 1a 00 00 00       	mov    $0x1a,%eax
 656:	cd 40                	int    $0x40
 658:	c3                   	ret    

00000659 <setuid>:
SYSCALL(setuid)
 659:	b8 1b 00 00 00       	mov    $0x1b,%eax
 65e:	cd 40                	int    $0x40
 660:	c3                   	ret    

00000661 <setgid>:
SYSCALL(setgid)
 661:	b8 1c 00 00 00       	mov    $0x1c,%eax
 666:	cd 40                	int    $0x40
 668:	c3                   	ret    

00000669 <getprocs>:
SYSCALL(getprocs)
 669:	b8 1d 00 00 00       	mov    $0x1d,%eax
 66e:	cd 40                	int    $0x40
 670:	c3                   	ret    

00000671 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 671:	55                   	push   %ebp
 672:	89 e5                	mov    %esp,%ebp
 674:	83 ec 18             	sub    $0x18,%esp
 677:	8b 45 0c             	mov    0xc(%ebp),%eax
 67a:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 67d:	83 ec 04             	sub    $0x4,%esp
 680:	6a 01                	push   $0x1
 682:	8d 45 f4             	lea    -0xc(%ebp),%eax
 685:	50                   	push   %eax
 686:	ff 75 08             	pushl  0x8(%ebp)
 689:	e8 23 ff ff ff       	call   5b1 <write>
 68e:	83 c4 10             	add    $0x10,%esp
}
 691:	90                   	nop
 692:	c9                   	leave  
 693:	c3                   	ret    

00000694 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 694:	55                   	push   %ebp
 695:	89 e5                	mov    %esp,%ebp
 697:	53                   	push   %ebx
 698:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 69b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6a2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6a6:	74 17                	je     6bf <printint+0x2b>
 6a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6ac:	79 11                	jns    6bf <printint+0x2b>
    neg = 1;
 6ae:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6b5:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b8:	f7 d8                	neg    %eax
 6ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6bd:	eb 06                	jmp    6c5 <printint+0x31>
  } else {
    x = xx;
 6bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6cc:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6cf:	8d 41 01             	lea    0x1(%ecx),%eax
 6d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6db:	ba 00 00 00 00       	mov    $0x0,%edx
 6e0:	f7 f3                	div    %ebx
 6e2:	89 d0                	mov    %edx,%eax
 6e4:	0f b6 80 08 0e 00 00 	movzbl 0xe08(%eax),%eax
 6eb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6f5:	ba 00 00 00 00       	mov    $0x0,%edx
 6fa:	f7 f3                	div    %ebx
 6fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 703:	75 c7                	jne    6cc <printint+0x38>
  if(neg)
 705:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 709:	74 2d                	je     738 <printint+0xa4>
    buf[i++] = '-';
 70b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 70e:	8d 50 01             	lea    0x1(%eax),%edx
 711:	89 55 f4             	mov    %edx,-0xc(%ebp)
 714:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 719:	eb 1d                	jmp    738 <printint+0xa4>
    putc(fd, buf[i]);
 71b:	8d 55 dc             	lea    -0x24(%ebp),%edx
 71e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 721:	01 d0                	add    %edx,%eax
 723:	0f b6 00             	movzbl (%eax),%eax
 726:	0f be c0             	movsbl %al,%eax
 729:	83 ec 08             	sub    $0x8,%esp
 72c:	50                   	push   %eax
 72d:	ff 75 08             	pushl  0x8(%ebp)
 730:	e8 3c ff ff ff       	call   671 <putc>
 735:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 738:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 73c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 740:	79 d9                	jns    71b <printint+0x87>
    putc(fd, buf[i]);
}
 742:	90                   	nop
 743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 746:	c9                   	leave  
 747:	c3                   	ret    

00000748 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 748:	55                   	push   %ebp
 749:	89 e5                	mov    %esp,%ebp
 74b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 74e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 755:	8d 45 0c             	lea    0xc(%ebp),%eax
 758:	83 c0 04             	add    $0x4,%eax
 75b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 75e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 765:	e9 59 01 00 00       	jmp    8c3 <printf+0x17b>
    c = fmt[i] & 0xff;
 76a:	8b 55 0c             	mov    0xc(%ebp),%edx
 76d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 770:	01 d0                	add    %edx,%eax
 772:	0f b6 00             	movzbl (%eax),%eax
 775:	0f be c0             	movsbl %al,%eax
 778:	25 ff 00 00 00       	and    $0xff,%eax
 77d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 780:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 784:	75 2c                	jne    7b2 <printf+0x6a>
      if(c == '%'){
 786:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 78a:	75 0c                	jne    798 <printf+0x50>
        state = '%';
 78c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 793:	e9 27 01 00 00       	jmp    8bf <printf+0x177>
      } else {
        putc(fd, c);
 798:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 79b:	0f be c0             	movsbl %al,%eax
 79e:	83 ec 08             	sub    $0x8,%esp
 7a1:	50                   	push   %eax
 7a2:	ff 75 08             	pushl  0x8(%ebp)
 7a5:	e8 c7 fe ff ff       	call   671 <putc>
 7aa:	83 c4 10             	add    $0x10,%esp
 7ad:	e9 0d 01 00 00       	jmp    8bf <printf+0x177>
      }
    } else if(state == '%'){
 7b2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7b6:	0f 85 03 01 00 00    	jne    8bf <printf+0x177>
      if(c == 'd'){
 7bc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7c0:	75 1e                	jne    7e0 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7c5:	8b 00                	mov    (%eax),%eax
 7c7:	6a 01                	push   $0x1
 7c9:	6a 0a                	push   $0xa
 7cb:	50                   	push   %eax
 7cc:	ff 75 08             	pushl  0x8(%ebp)
 7cf:	e8 c0 fe ff ff       	call   694 <printint>
 7d4:	83 c4 10             	add    $0x10,%esp
        ap++;
 7d7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7db:	e9 d8 00 00 00       	jmp    8b8 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7e0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7e4:	74 06                	je     7ec <printf+0xa4>
 7e6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7ea:	75 1e                	jne    80a <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7ef:	8b 00                	mov    (%eax),%eax
 7f1:	6a 00                	push   $0x0
 7f3:	6a 10                	push   $0x10
 7f5:	50                   	push   %eax
 7f6:	ff 75 08             	pushl  0x8(%ebp)
 7f9:	e8 96 fe ff ff       	call   694 <printint>
 7fe:	83 c4 10             	add    $0x10,%esp
        ap++;
 801:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 805:	e9 ae 00 00 00       	jmp    8b8 <printf+0x170>
      } else if(c == 's'){
 80a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 80e:	75 43                	jne    853 <printf+0x10b>
        s = (char*)*ap;
 810:	8b 45 e8             	mov    -0x18(%ebp),%eax
 813:	8b 00                	mov    (%eax),%eax
 815:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 818:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 81c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 820:	75 25                	jne    847 <printf+0xff>
          s = "(null)";
 822:	c7 45 f4 8f 0b 00 00 	movl   $0xb8f,-0xc(%ebp)
        while(*s != 0){
 829:	eb 1c                	jmp    847 <printf+0xff>
          putc(fd, *s);
 82b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82e:	0f b6 00             	movzbl (%eax),%eax
 831:	0f be c0             	movsbl %al,%eax
 834:	83 ec 08             	sub    $0x8,%esp
 837:	50                   	push   %eax
 838:	ff 75 08             	pushl  0x8(%ebp)
 83b:	e8 31 fe ff ff       	call   671 <putc>
 840:	83 c4 10             	add    $0x10,%esp
          s++;
 843:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 847:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84a:	0f b6 00             	movzbl (%eax),%eax
 84d:	84 c0                	test   %al,%al
 84f:	75 da                	jne    82b <printf+0xe3>
 851:	eb 65                	jmp    8b8 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 853:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 857:	75 1d                	jne    876 <printf+0x12e>
        putc(fd, *ap);
 859:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85c:	8b 00                	mov    (%eax),%eax
 85e:	0f be c0             	movsbl %al,%eax
 861:	83 ec 08             	sub    $0x8,%esp
 864:	50                   	push   %eax
 865:	ff 75 08             	pushl  0x8(%ebp)
 868:	e8 04 fe ff ff       	call   671 <putc>
 86d:	83 c4 10             	add    $0x10,%esp
        ap++;
 870:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 874:	eb 42                	jmp    8b8 <printf+0x170>
      } else if(c == '%'){
 876:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 87a:	75 17                	jne    893 <printf+0x14b>
        putc(fd, c);
 87c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 87f:	0f be c0             	movsbl %al,%eax
 882:	83 ec 08             	sub    $0x8,%esp
 885:	50                   	push   %eax
 886:	ff 75 08             	pushl  0x8(%ebp)
 889:	e8 e3 fd ff ff       	call   671 <putc>
 88e:	83 c4 10             	add    $0x10,%esp
 891:	eb 25                	jmp    8b8 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 893:	83 ec 08             	sub    $0x8,%esp
 896:	6a 25                	push   $0x25
 898:	ff 75 08             	pushl  0x8(%ebp)
 89b:	e8 d1 fd ff ff       	call   671 <putc>
 8a0:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 8a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a6:	0f be c0             	movsbl %al,%eax
 8a9:	83 ec 08             	sub    $0x8,%esp
 8ac:	50                   	push   %eax
 8ad:	ff 75 08             	pushl  0x8(%ebp)
 8b0:	e8 bc fd ff ff       	call   671 <putc>
 8b5:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8b8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8bf:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8c3:	8b 55 0c             	mov    0xc(%ebp),%edx
 8c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c9:	01 d0                	add    %edx,%eax
 8cb:	0f b6 00             	movzbl (%eax),%eax
 8ce:	84 c0                	test   %al,%al
 8d0:	0f 85 94 fe ff ff    	jne    76a <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8d6:	90                   	nop
 8d7:	c9                   	leave  
 8d8:	c3                   	ret    

000008d9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8d9:	55                   	push   %ebp
 8da:	89 e5                	mov    %esp,%ebp
 8dc:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8df:	8b 45 08             	mov    0x8(%ebp),%eax
 8e2:	83 e8 08             	sub    $0x8,%eax
 8e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e8:	a1 24 0e 00 00       	mov    0xe24,%eax
 8ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8f0:	eb 24                	jmp    916 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f5:	8b 00                	mov    (%eax),%eax
 8f7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8fa:	77 12                	ja     90e <free+0x35>
 8fc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ff:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 902:	77 24                	ja     928 <free+0x4f>
 904:	8b 45 fc             	mov    -0x4(%ebp),%eax
 907:	8b 00                	mov    (%eax),%eax
 909:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 90c:	77 1a                	ja     928 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 90e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 911:	8b 00                	mov    (%eax),%eax
 913:	89 45 fc             	mov    %eax,-0x4(%ebp)
 916:	8b 45 f8             	mov    -0x8(%ebp),%eax
 919:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 91c:	76 d4                	jbe    8f2 <free+0x19>
 91e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 921:	8b 00                	mov    (%eax),%eax
 923:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 926:	76 ca                	jbe    8f2 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 928:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92b:	8b 40 04             	mov    0x4(%eax),%eax
 92e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 935:	8b 45 f8             	mov    -0x8(%ebp),%eax
 938:	01 c2                	add    %eax,%edx
 93a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93d:	8b 00                	mov    (%eax),%eax
 93f:	39 c2                	cmp    %eax,%edx
 941:	75 24                	jne    967 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 943:	8b 45 f8             	mov    -0x8(%ebp),%eax
 946:	8b 50 04             	mov    0x4(%eax),%edx
 949:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94c:	8b 00                	mov    (%eax),%eax
 94e:	8b 40 04             	mov    0x4(%eax),%eax
 951:	01 c2                	add    %eax,%edx
 953:	8b 45 f8             	mov    -0x8(%ebp),%eax
 956:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 00                	mov    (%eax),%eax
 95e:	8b 10                	mov    (%eax),%edx
 960:	8b 45 f8             	mov    -0x8(%ebp),%eax
 963:	89 10                	mov    %edx,(%eax)
 965:	eb 0a                	jmp    971 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 967:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96a:	8b 10                	mov    (%eax),%edx
 96c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96f:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 971:	8b 45 fc             	mov    -0x4(%ebp),%eax
 974:	8b 40 04             	mov    0x4(%eax),%eax
 977:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 97e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 981:	01 d0                	add    %edx,%eax
 983:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 986:	75 20                	jne    9a8 <free+0xcf>
    p->s.size += bp->s.size;
 988:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98b:	8b 50 04             	mov    0x4(%eax),%edx
 98e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 991:	8b 40 04             	mov    0x4(%eax),%eax
 994:	01 c2                	add    %eax,%edx
 996:	8b 45 fc             	mov    -0x4(%ebp),%eax
 999:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 99c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99f:	8b 10                	mov    (%eax),%edx
 9a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a4:	89 10                	mov    %edx,(%eax)
 9a6:	eb 08                	jmp    9b0 <free+0xd7>
  } else
    p->s.ptr = bp;
 9a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ab:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9ae:	89 10                	mov    %edx,(%eax)
  freep = p;
 9b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b3:	a3 24 0e 00 00       	mov    %eax,0xe24
}
 9b8:	90                   	nop
 9b9:	c9                   	leave  
 9ba:	c3                   	ret    

000009bb <morecore>:

static Header*
morecore(uint nu)
{
 9bb:	55                   	push   %ebp
 9bc:	89 e5                	mov    %esp,%ebp
 9be:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9c1:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9c8:	77 07                	ja     9d1 <morecore+0x16>
    nu = 4096;
 9ca:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9d1:	8b 45 08             	mov    0x8(%ebp),%eax
 9d4:	c1 e0 03             	shl    $0x3,%eax
 9d7:	83 ec 0c             	sub    $0xc,%esp
 9da:	50                   	push   %eax
 9db:	e8 39 fc ff ff       	call   619 <sbrk>
 9e0:	83 c4 10             	add    $0x10,%esp
 9e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9e6:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9ea:	75 07                	jne    9f3 <morecore+0x38>
    return 0;
 9ec:	b8 00 00 00 00       	mov    $0x0,%eax
 9f1:	eb 26                	jmp    a19 <morecore+0x5e>
  hp = (Header*)p;
 9f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9fc:	8b 55 08             	mov    0x8(%ebp),%edx
 9ff:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a05:	83 c0 08             	add    $0x8,%eax
 a08:	83 ec 0c             	sub    $0xc,%esp
 a0b:	50                   	push   %eax
 a0c:	e8 c8 fe ff ff       	call   8d9 <free>
 a11:	83 c4 10             	add    $0x10,%esp
  return freep;
 a14:	a1 24 0e 00 00       	mov    0xe24,%eax
}
 a19:	c9                   	leave  
 a1a:	c3                   	ret    

00000a1b <malloc>:

void*
malloc(uint nbytes)
{
 a1b:	55                   	push   %ebp
 a1c:	89 e5                	mov    %esp,%ebp
 a1e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a21:	8b 45 08             	mov    0x8(%ebp),%eax
 a24:	83 c0 07             	add    $0x7,%eax
 a27:	c1 e8 03             	shr    $0x3,%eax
 a2a:	83 c0 01             	add    $0x1,%eax
 a2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a30:	a1 24 0e 00 00       	mov    0xe24,%eax
 a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a3c:	75 23                	jne    a61 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a3e:	c7 45 f0 1c 0e 00 00 	movl   $0xe1c,-0x10(%ebp)
 a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a48:	a3 24 0e 00 00       	mov    %eax,0xe24
 a4d:	a1 24 0e 00 00       	mov    0xe24,%eax
 a52:	a3 1c 0e 00 00       	mov    %eax,0xe1c
    base.s.size = 0;
 a57:	c7 05 20 0e 00 00 00 	movl   $0x0,0xe20
 a5e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a64:	8b 00                	mov    (%eax),%eax
 a66:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a6c:	8b 40 04             	mov    0x4(%eax),%eax
 a6f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a72:	72 4d                	jb     ac1 <malloc+0xa6>
      if(p->s.size == nunits)
 a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a77:	8b 40 04             	mov    0x4(%eax),%eax
 a7a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a7d:	75 0c                	jne    a8b <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a82:	8b 10                	mov    (%eax),%edx
 a84:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a87:	89 10                	mov    %edx,(%eax)
 a89:	eb 26                	jmp    ab1 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8e:	8b 40 04             	mov    0x4(%eax),%eax
 a91:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a94:	89 c2                	mov    %eax,%edx
 a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a99:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9f:	8b 40 04             	mov    0x4(%eax),%eax
 aa2:	c1 e0 03             	shl    $0x3,%eax
 aa5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aab:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aae:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ab1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab4:	a3 24 0e 00 00       	mov    %eax,0xe24
      return (void*)(p + 1);
 ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abc:	83 c0 08             	add    $0x8,%eax
 abf:	eb 3b                	jmp    afc <malloc+0xe1>
    }
    if(p == freep)
 ac1:	a1 24 0e 00 00       	mov    0xe24,%eax
 ac6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ac9:	75 1e                	jne    ae9 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 acb:	83 ec 0c             	sub    $0xc,%esp
 ace:	ff 75 ec             	pushl  -0x14(%ebp)
 ad1:	e8 e5 fe ff ff       	call   9bb <morecore>
 ad6:	83 c4 10             	add    $0x10,%esp
 ad9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 adc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ae0:	75 07                	jne    ae9 <malloc+0xce>
        return 0;
 ae2:	b8 00 00 00 00       	mov    $0x0,%eax
 ae7:	eb 13                	jmp    afc <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af2:	8b 00                	mov    (%eax),%eax
 af4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 af7:	e9 6d ff ff ff       	jmp    a69 <malloc+0x4e>
}
 afc:	c9                   	leave  
 afd:	c3                   	ret    
