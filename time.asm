
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <display_result>:
#ifdef CS333_P2
#include "types.h"
#include "user.h"

void
display_result(char* name, int millisec) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  if (name)
   6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   a:	74 15                	je     21 <display_result+0x21>
    printf(1,"%s ", name);
   c:	83 ec 04             	sub    $0x4,%esp
   f:	ff 75 08             	pushl  0x8(%ebp)
  12:	68 f0 0a 00 00       	push   $0xaf0
  17:	6a 01                	push   $0x1
  19:	e8 1c 07 00 00       	call   73a <printf>
  1e:	83 c4 10             	add    $0x10,%esp

  printf(1,"ran in %d", millisec / 1000);
  21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  24:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  29:	89 c8                	mov    %ecx,%eax
  2b:	f7 ea                	imul   %edx
  2d:	c1 fa 06             	sar    $0x6,%edx
  30:	89 c8                	mov    %ecx,%eax
  32:	c1 f8 1f             	sar    $0x1f,%eax
  35:	29 c2                	sub    %eax,%edx
  37:	89 d0                	mov    %edx,%eax
  39:	83 ec 04             	sub    $0x4,%esp
  3c:	50                   	push   %eax
  3d:	68 f4 0a 00 00       	push   $0xaf4
  42:	6a 01                	push   $0x1
  44:	e8 f1 06 00 00       	call   73a <printf>
  49:	83 c4 10             	add    $0x10,%esp

  millisec %= 1000;
  4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  4f:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
  54:	89 c8                	mov    %ecx,%eax
  56:	f7 ea                	imul   %edx
  58:	c1 fa 06             	sar    $0x6,%edx
  5b:	89 c8                	mov    %ecx,%eax
  5d:	c1 f8 1f             	sar    $0x1f,%eax
  60:	29 c2                	sub    %eax,%edx
  62:	89 d0                	mov    %edx,%eax
  64:	69 c0 e8 03 00 00    	imul   $0x3e8,%eax,%eax
  6a:	29 c1                	sub    %eax,%ecx
  6c:	89 c8                	mov    %ecx,%eax
  6e:	89 45 0c             	mov    %eax,0xc(%ebp)
  if (millisec)
  71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  75:	74 12                	je     89 <display_result+0x89>
    printf(1,".");
  77:	83 ec 08             	sub    $0x8,%esp
  7a:	68 fe 0a 00 00       	push   $0xafe
  7f:	6a 01                	push   $0x1
  81:	e8 b4 06 00 00       	call   73a <printf>
  86:	83 c4 10             	add    $0x10,%esp

  if (millisec < 100 && millisec > 0)
  89:	83 7d 0c 63          	cmpl   $0x63,0xc(%ebp)
  8d:	7f 1a                	jg     a9 <display_result+0xa9>
  8f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  93:	7e 14                	jle    a9 <display_result+0xa9>
    printf(1,"0");
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 00 0b 00 00       	push   $0xb00
  9d:	6a 01                	push   $0x1
  9f:	e8 96 06 00 00       	call   73a <printf>
  a4:	83 c4 10             	add    $0x10,%esp
  a7:	eb 2b                	jmp    d4 <display_result+0xd4>
  else
    printf(1,"%d", millisec/100);
  a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ac:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  b1:	89 c8                	mov    %ecx,%eax
  b3:	f7 ea                	imul   %edx
  b5:	c1 fa 05             	sar    $0x5,%edx
  b8:	89 c8                	mov    %ecx,%eax
  ba:	c1 f8 1f             	sar    $0x1f,%eax
  bd:	29 c2                	sub    %eax,%edx
  bf:	89 d0                	mov    %edx,%eax
  c1:	83 ec 04             	sub    $0x4,%esp
  c4:	50                   	push   %eax
  c5:	68 02 0b 00 00       	push   $0xb02
  ca:	6a 01                	push   $0x1
  cc:	e8 69 06 00 00       	call   73a <printf>
  d1:	83 c4 10             	add    $0x10,%esp

  millisec %= 100;
  d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  d7:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  dc:	89 c8                	mov    %ecx,%eax
  de:	f7 ea                	imul   %edx
  e0:	c1 fa 05             	sar    $0x5,%edx
  e3:	89 c8                	mov    %ecx,%eax
  e5:	c1 f8 1f             	sar    $0x1f,%eax
  e8:	29 c2                	sub    %eax,%edx
  ea:	89 d0                	mov    %edx,%eax
  ec:	6b c0 64             	imul   $0x64,%eax,%eax
  ef:	29 c1                	sub    %eax,%ecx
  f1:	89 c8                	mov    %ecx,%eax
  f3:	89 45 0c             	mov    %eax,0xc(%ebp)
  if (millisec < 10 && millisec > 0)
  f6:	83 7d 0c 09          	cmpl   $0x9,0xc(%ebp)
  fa:	7f 1a                	jg     116 <display_result+0x116>
  fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 100:	7e 14                	jle    116 <display_result+0x116>
    printf(1,"0");
 102:	83 ec 08             	sub    $0x8,%esp
 105:	68 00 0b 00 00       	push   $0xb00
 10a:	6a 01                	push   $0x1
 10c:	e8 29 06 00 00       	call   73a <printf>
 111:	83 c4 10             	add    $0x10,%esp
 114:	eb 2b                	jmp    141 <display_result+0x141>
  else
    printf(1,"%d", millisec/10);
 116:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 119:	ba 67 66 66 66       	mov    $0x66666667,%edx
 11e:	89 c8                	mov    %ecx,%eax
 120:	f7 ea                	imul   %edx
 122:	c1 fa 02             	sar    $0x2,%edx
 125:	89 c8                	mov    %ecx,%eax
 127:	c1 f8 1f             	sar    $0x1f,%eax
 12a:	29 c2                	sub    %eax,%edx
 12c:	89 d0                	mov    %edx,%eax
 12e:	83 ec 04             	sub    $0x4,%esp
 131:	50                   	push   %eax
 132:	68 02 0b 00 00       	push   $0xb02
 137:	6a 01                	push   $0x1
 139:	e8 fc 05 00 00       	call   73a <printf>
 13e:	83 c4 10             	add    $0x10,%esp

  if (millisec%=10)
 141:	8b 4d 0c             	mov    0xc(%ebp),%ecx
 144:	ba 67 66 66 66       	mov    $0x66666667,%edx
 149:	89 c8                	mov    %ecx,%eax
 14b:	f7 ea                	imul   %edx
 14d:	c1 fa 02             	sar    $0x2,%edx
 150:	89 c8                	mov    %ecx,%eax
 152:	c1 f8 1f             	sar    $0x1f,%eax
 155:	29 c2                	sub    %eax,%edx
 157:	89 d0                	mov    %edx,%eax
 159:	c1 e0 02             	shl    $0x2,%eax
 15c:	01 d0                	add    %edx,%eax
 15e:	01 c0                	add    %eax,%eax
 160:	29 c1                	sub    %eax,%ecx
 162:	89 c8                	mov    %ecx,%eax
 164:	89 45 0c             	mov    %eax,0xc(%ebp)
 167:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 16b:	74 15                	je     182 <display_result+0x182>
    printf(1,"%d", millisec);
 16d:	83 ec 04             	sub    $0x4,%esp
 170:	ff 75 0c             	pushl  0xc(%ebp)
 173:	68 02 0b 00 00       	push   $0xb02
 178:	6a 01                	push   $0x1
 17a:	e8 bb 05 00 00       	call   73a <printf>
 17f:	83 c4 10             	add    $0x10,%esp

  printf(1," seconds\n");
 182:	83 ec 08             	sub    $0x8,%esp
 185:	68 05 0b 00 00       	push   $0xb05
 18a:	6a 01                	push   $0x1
 18c:	e8 a9 05 00 00       	call   73a <printf>
 191:	83 c4 10             	add    $0x10,%esp
}
 194:	90                   	nop
 195:	c9                   	leave  
 196:	c3                   	ret    

00000197 <main>:

int
main(int argc, char* argv[])
{
 197:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 19b:	83 e4 f0             	and    $0xfffffff0,%esp
 19e:	ff 71 fc             	pushl  -0x4(%ecx)
 1a1:	55                   	push   %ebp
 1a2:	89 e5                	mov    %esp,%ebp
 1a4:	53                   	push   %ebx
 1a5:	51                   	push   %ecx
 1a6:	83 ec 10             	sub    $0x10,%esp
 1a9:	89 cb                	mov    %ecx,%ebx
  int start, forkflag;

  if (argc == 1)
 1ab:	83 3b 01             	cmpl   $0x1,(%ebx)
 1ae:	75 12                	jne    1c2 <main+0x2b>
    printf(2,"No program name provided... ");
 1b0:	83 ec 08             	sub    $0x8,%esp
 1b3:	68 0f 0b 00 00       	push   $0xb0f
 1b8:	6a 02                	push   $0x2
 1ba:	e8 7b 05 00 00       	call   73a <printf>
 1bf:	83 c4 10             	add    $0x10,%esp

  start = uptime();
 1c2:	e8 54 04 00 00       	call   61b <uptime>
 1c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  forkflag = fork();
 1ca:	e8 ac 03 00 00       	call   57b <fork>
 1cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (forkflag < 0) {
 1d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1d6:	79 17                	jns    1ef <main+0x58>
    printf(2,"fork() error");
 1d8:	83 ec 08             	sub    $0x8,%esp
 1db:	68 2c 0b 00 00       	push   $0xb2c
 1e0:	6a 02                	push   $0x2
 1e2:	e8 53 05 00 00       	call   73a <printf>
 1e7:	83 c4 10             	add    $0x10,%esp
    exit();
 1ea:	e8 94 03 00 00       	call   583 <exit>
  }

  if (forkflag > 0) {
 1ef:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1f3:	7e 29                	jle    21e <main+0x87>
    wait();
 1f5:	e8 91 03 00 00       	call   58b <wait>
    display_result(argv[1], uptime() - start);
 1fa:	e8 1c 04 00 00       	call   61b <uptime>
 1ff:	2b 45 f4             	sub    -0xc(%ebp),%eax
 202:	89 c2                	mov    %eax,%edx
 204:	8b 43 04             	mov    0x4(%ebx),%eax
 207:	83 c0 04             	add    $0x4,%eax
 20a:	8b 00                	mov    (%eax),%eax
 20c:	83 ec 08             	sub    $0x8,%esp
 20f:	52                   	push   %edx
 210:	50                   	push   %eax
 211:	e8 ea fd ff ff       	call   0 <display_result>
 216:	83 c4 10             	add    $0x10,%esp
    exit();
 219:	e8 65 03 00 00       	call   583 <exit>
  }

  exec(argv[1], argv+1);
 21e:	8b 43 04             	mov    0x4(%ebx),%eax
 221:	8d 50 04             	lea    0x4(%eax),%edx
 224:	8b 43 04             	mov    0x4(%ebx),%eax
 227:	83 c0 04             	add    $0x4,%eax
 22a:	8b 00                	mov    (%eax),%eax
 22c:	83 ec 08             	sub    $0x8,%esp
 22f:	52                   	push   %edx
 230:	50                   	push   %eax
 231:	e8 85 03 00 00       	call   5bb <exec>
 236:	83 c4 10             	add    $0x10,%esp
  // should not return
  printf(2,"%s failed\n", argv[1]);
 239:	8b 43 04             	mov    0x4(%ebx),%eax
 23c:	83 c0 04             	add    $0x4,%eax
 23f:	8b 00                	mov    (%eax),%eax
 241:	83 ec 04             	sub    $0x4,%esp
 244:	50                   	push   %eax
 245:	68 39 0b 00 00       	push   $0xb39
 24a:	6a 02                	push   $0x2
 24c:	e8 e9 04 00 00       	call   73a <printf>
 251:	83 c4 10             	add    $0x10,%esp

  exit();
 254:	e8 2a 03 00 00       	call   583 <exit>

00000259 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 259:	55                   	push   %ebp
 25a:	89 e5                	mov    %esp,%ebp
 25c:	57                   	push   %edi
 25d:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 25e:	8b 4d 08             	mov    0x8(%ebp),%ecx
 261:	8b 55 10             	mov    0x10(%ebp),%edx
 264:	8b 45 0c             	mov    0xc(%ebp),%eax
 267:	89 cb                	mov    %ecx,%ebx
 269:	89 df                	mov    %ebx,%edi
 26b:	89 d1                	mov    %edx,%ecx
 26d:	fc                   	cld    
 26e:	f3 aa                	rep stos %al,%es:(%edi)
 270:	89 ca                	mov    %ecx,%edx
 272:	89 fb                	mov    %edi,%ebx
 274:	89 5d 08             	mov    %ebx,0x8(%ebp)
 277:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 27a:	90                   	nop
 27b:	5b                   	pop    %ebx
 27c:	5f                   	pop    %edi
 27d:	5d                   	pop    %ebp
 27e:	c3                   	ret    

0000027f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 27f:	55                   	push   %ebp
 280:	89 e5                	mov    %esp,%ebp
 282:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 285:	8b 45 08             	mov    0x8(%ebp),%eax
 288:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 28b:	90                   	nop
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	8d 50 01             	lea    0x1(%eax),%edx
 292:	89 55 08             	mov    %edx,0x8(%ebp)
 295:	8b 55 0c             	mov    0xc(%ebp),%edx
 298:	8d 4a 01             	lea    0x1(%edx),%ecx
 29b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 29e:	0f b6 12             	movzbl (%edx),%edx
 2a1:	88 10                	mov    %dl,(%eax)
 2a3:	0f b6 00             	movzbl (%eax),%eax
 2a6:	84 c0                	test   %al,%al
 2a8:	75 e2                	jne    28c <strcpy+0xd>
    ;
  return os;
 2aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ad:	c9                   	leave  
 2ae:	c3                   	ret    

000002af <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2b2:	eb 08                	jmp    2bc <strcmp+0xd>
    p++, q++;
 2b4:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2b8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2bc:	8b 45 08             	mov    0x8(%ebp),%eax
 2bf:	0f b6 00             	movzbl (%eax),%eax
 2c2:	84 c0                	test   %al,%al
 2c4:	74 10                	je     2d6 <strcmp+0x27>
 2c6:	8b 45 08             	mov    0x8(%ebp),%eax
 2c9:	0f b6 10             	movzbl (%eax),%edx
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	38 c2                	cmp    %al,%dl
 2d4:	74 de                	je     2b4 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2d6:	8b 45 08             	mov    0x8(%ebp),%eax
 2d9:	0f b6 00             	movzbl (%eax),%eax
 2dc:	0f b6 d0             	movzbl %al,%edx
 2df:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e2:	0f b6 00             	movzbl (%eax),%eax
 2e5:	0f b6 c0             	movzbl %al,%eax
 2e8:	29 c2                	sub    %eax,%edx
 2ea:	89 d0                	mov    %edx,%eax
}
 2ec:	5d                   	pop    %ebp
 2ed:	c3                   	ret    

000002ee <strlen>:

uint
strlen(char *s)
{
 2ee:	55                   	push   %ebp
 2ef:	89 e5                	mov    %esp,%ebp
 2f1:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 2f4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 2fb:	eb 04                	jmp    301 <strlen+0x13>
 2fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 301:	8b 55 fc             	mov    -0x4(%ebp),%edx
 304:	8b 45 08             	mov    0x8(%ebp),%eax
 307:	01 d0                	add    %edx,%eax
 309:	0f b6 00             	movzbl (%eax),%eax
 30c:	84 c0                	test   %al,%al
 30e:	75 ed                	jne    2fd <strlen+0xf>
    ;
  return n;
 310:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 313:	c9                   	leave  
 314:	c3                   	ret    

00000315 <memset>:

void*
memset(void *dst, int c, uint n)
{
 315:	55                   	push   %ebp
 316:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 318:	8b 45 10             	mov    0x10(%ebp),%eax
 31b:	50                   	push   %eax
 31c:	ff 75 0c             	pushl  0xc(%ebp)
 31f:	ff 75 08             	pushl  0x8(%ebp)
 322:	e8 32 ff ff ff       	call   259 <stosb>
 327:	83 c4 0c             	add    $0xc,%esp
  return dst;
 32a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 32d:	c9                   	leave  
 32e:	c3                   	ret    

0000032f <strchr>:

char*
strchr(const char *s, char c)
{
 32f:	55                   	push   %ebp
 330:	89 e5                	mov    %esp,%ebp
 332:	83 ec 04             	sub    $0x4,%esp
 335:	8b 45 0c             	mov    0xc(%ebp),%eax
 338:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 33b:	eb 14                	jmp    351 <strchr+0x22>
    if(*s == c)
 33d:	8b 45 08             	mov    0x8(%ebp),%eax
 340:	0f b6 00             	movzbl (%eax),%eax
 343:	3a 45 fc             	cmp    -0x4(%ebp),%al
 346:	75 05                	jne    34d <strchr+0x1e>
      return (char*)s;
 348:	8b 45 08             	mov    0x8(%ebp),%eax
 34b:	eb 13                	jmp    360 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 34d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 351:	8b 45 08             	mov    0x8(%ebp),%eax
 354:	0f b6 00             	movzbl (%eax),%eax
 357:	84 c0                	test   %al,%al
 359:	75 e2                	jne    33d <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 35b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 360:	c9                   	leave  
 361:	c3                   	ret    

00000362 <gets>:

char*
gets(char *buf, int max)
{
 362:	55                   	push   %ebp
 363:	89 e5                	mov    %esp,%ebp
 365:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 368:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 36f:	eb 42                	jmp    3b3 <gets+0x51>
    cc = read(0, &c, 1);
 371:	83 ec 04             	sub    $0x4,%esp
 374:	6a 01                	push   $0x1
 376:	8d 45 ef             	lea    -0x11(%ebp),%eax
 379:	50                   	push   %eax
 37a:	6a 00                	push   $0x0
 37c:	e8 1a 02 00 00       	call   59b <read>
 381:	83 c4 10             	add    $0x10,%esp
 384:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 387:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 38b:	7e 33                	jle    3c0 <gets+0x5e>
      break;
    buf[i++] = c;
 38d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 390:	8d 50 01             	lea    0x1(%eax),%edx
 393:	89 55 f4             	mov    %edx,-0xc(%ebp)
 396:	89 c2                	mov    %eax,%edx
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	01 c2                	add    %eax,%edx
 39d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a1:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3a3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3a7:	3c 0a                	cmp    $0xa,%al
 3a9:	74 16                	je     3c1 <gets+0x5f>
 3ab:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3af:	3c 0d                	cmp    $0xd,%al
 3b1:	74 0e                	je     3c1 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3b6:	83 c0 01             	add    $0x1,%eax
 3b9:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3bc:	7c b3                	jl     371 <gets+0xf>
 3be:	eb 01                	jmp    3c1 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3c0:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	01 d0                	add    %edx,%eax
 3c9:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3cc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3cf:	c9                   	leave  
 3d0:	c3                   	ret    

000003d1 <stat>:

int
stat(char *n, struct stat *st)
{
 3d1:	55                   	push   %ebp
 3d2:	89 e5                	mov    %esp,%ebp
 3d4:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3d7:	83 ec 08             	sub    $0x8,%esp
 3da:	6a 00                	push   $0x0
 3dc:	ff 75 08             	pushl  0x8(%ebp)
 3df:	e8 df 01 00 00       	call   5c3 <open>
 3e4:	83 c4 10             	add    $0x10,%esp
 3e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3ee:	79 07                	jns    3f7 <stat+0x26>
    return -1;
 3f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 3f5:	eb 25                	jmp    41c <stat+0x4b>
  r = fstat(fd, st);
 3f7:	83 ec 08             	sub    $0x8,%esp
 3fa:	ff 75 0c             	pushl  0xc(%ebp)
 3fd:	ff 75 f4             	pushl  -0xc(%ebp)
 400:	e8 d6 01 00 00       	call   5db <fstat>
 405:	83 c4 10             	add    $0x10,%esp
 408:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 40b:	83 ec 0c             	sub    $0xc,%esp
 40e:	ff 75 f4             	pushl  -0xc(%ebp)
 411:	e8 95 01 00 00       	call   5ab <close>
 416:	83 c4 10             	add    $0x10,%esp
  return r;
 419:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 41c:	c9                   	leave  
 41d:	c3                   	ret    

0000041e <atoi>:

int
atoi(const char *s)
{
 41e:	55                   	push   %ebp
 41f:	89 e5                	mov    %esp,%ebp
 421:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 424:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 42b:	eb 04                	jmp    431 <atoi+0x13>
 42d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 431:	8b 45 08             	mov    0x8(%ebp),%eax
 434:	0f b6 00             	movzbl (%eax),%eax
 437:	3c 20                	cmp    $0x20,%al
 439:	74 f2                	je     42d <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 43b:	8b 45 08             	mov    0x8(%ebp),%eax
 43e:	0f b6 00             	movzbl (%eax),%eax
 441:	3c 2d                	cmp    $0x2d,%al
 443:	75 07                	jne    44c <atoi+0x2e>
 445:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 44a:	eb 05                	jmp    451 <atoi+0x33>
 44c:	b8 01 00 00 00       	mov    $0x1,%eax
 451:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 454:	8b 45 08             	mov    0x8(%ebp),%eax
 457:	0f b6 00             	movzbl (%eax),%eax
 45a:	3c 2b                	cmp    $0x2b,%al
 45c:	74 0a                	je     468 <atoi+0x4a>
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	3c 2d                	cmp    $0x2d,%al
 466:	75 2b                	jne    493 <atoi+0x75>
    s++;
 468:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 46c:	eb 25                	jmp    493 <atoi+0x75>
    n = n*10 + *s++ - '0';
 46e:	8b 55 fc             	mov    -0x4(%ebp),%edx
 471:	89 d0                	mov    %edx,%eax
 473:	c1 e0 02             	shl    $0x2,%eax
 476:	01 d0                	add    %edx,%eax
 478:	01 c0                	add    %eax,%eax
 47a:	89 c1                	mov    %eax,%ecx
 47c:	8b 45 08             	mov    0x8(%ebp),%eax
 47f:	8d 50 01             	lea    0x1(%eax),%edx
 482:	89 55 08             	mov    %edx,0x8(%ebp)
 485:	0f b6 00             	movzbl (%eax),%eax
 488:	0f be c0             	movsbl %al,%eax
 48b:	01 c8                	add    %ecx,%eax
 48d:	83 e8 30             	sub    $0x30,%eax
 490:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 493:	8b 45 08             	mov    0x8(%ebp),%eax
 496:	0f b6 00             	movzbl (%eax),%eax
 499:	3c 2f                	cmp    $0x2f,%al
 49b:	7e 0a                	jle    4a7 <atoi+0x89>
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	0f b6 00             	movzbl (%eax),%eax
 4a3:	3c 39                	cmp    $0x39,%al
 4a5:	7e c7                	jle    46e <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 4a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 4aa:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 4ae:	c9                   	leave  
 4af:	c3                   	ret    

000004b0 <atoo>:

int
atoo(const char *s)
{
 4b0:	55                   	push   %ebp
 4b1:	89 e5                	mov    %esp,%ebp
 4b3:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4bd:	eb 04                	jmp    4c3 <atoo+0x13>
 4bf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4c3:	8b 45 08             	mov    0x8(%ebp),%eax
 4c6:	0f b6 00             	movzbl (%eax),%eax
 4c9:	3c 20                	cmp    $0x20,%al
 4cb:	74 f2                	je     4bf <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	0f b6 00             	movzbl (%eax),%eax
 4d3:	3c 2d                	cmp    $0x2d,%al
 4d5:	75 07                	jne    4de <atoo+0x2e>
 4d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4dc:	eb 05                	jmp    4e3 <atoo+0x33>
 4de:	b8 01 00 00 00       	mov    $0x1,%eax
 4e3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 4e6:	8b 45 08             	mov    0x8(%ebp),%eax
 4e9:	0f b6 00             	movzbl (%eax),%eax
 4ec:	3c 2b                	cmp    $0x2b,%al
 4ee:	74 0a                	je     4fa <atoo+0x4a>
 4f0:	8b 45 08             	mov    0x8(%ebp),%eax
 4f3:	0f b6 00             	movzbl (%eax),%eax
 4f6:	3c 2d                	cmp    $0x2d,%al
 4f8:	75 27                	jne    521 <atoo+0x71>
    s++;
 4fa:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 4fe:	eb 21                	jmp    521 <atoo+0x71>
    n = n*8 + *s++ - '0';
 500:	8b 45 fc             	mov    -0x4(%ebp),%eax
 503:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 50a:	8b 45 08             	mov    0x8(%ebp),%eax
 50d:	8d 50 01             	lea    0x1(%eax),%edx
 510:	89 55 08             	mov    %edx,0x8(%ebp)
 513:	0f b6 00             	movzbl (%eax),%eax
 516:	0f be c0             	movsbl %al,%eax
 519:	01 c8                	add    %ecx,%eax
 51b:	83 e8 30             	sub    $0x30,%eax
 51e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 521:	8b 45 08             	mov    0x8(%ebp),%eax
 524:	0f b6 00             	movzbl (%eax),%eax
 527:	3c 2f                	cmp    $0x2f,%al
 529:	7e 0a                	jle    535 <atoo+0x85>
 52b:	8b 45 08             	mov    0x8(%ebp),%eax
 52e:	0f b6 00             	movzbl (%eax),%eax
 531:	3c 37                	cmp    $0x37,%al
 533:	7e cb                	jle    500 <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 535:	8b 45 f8             	mov    -0x8(%ebp),%eax
 538:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 53c:	c9                   	leave  
 53d:	c3                   	ret    

0000053e <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 53e:	55                   	push   %ebp
 53f:	89 e5                	mov    %esp,%ebp
 541:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 544:	8b 45 08             	mov    0x8(%ebp),%eax
 547:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 54a:	8b 45 0c             	mov    0xc(%ebp),%eax
 54d:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 550:	eb 17                	jmp    569 <memmove+0x2b>
    *dst++ = *src++;
 552:	8b 45 fc             	mov    -0x4(%ebp),%eax
 555:	8d 50 01             	lea    0x1(%eax),%edx
 558:	89 55 fc             	mov    %edx,-0x4(%ebp)
 55b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 55e:	8d 4a 01             	lea    0x1(%edx),%ecx
 561:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 564:	0f b6 12             	movzbl (%edx),%edx
 567:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 569:	8b 45 10             	mov    0x10(%ebp),%eax
 56c:	8d 50 ff             	lea    -0x1(%eax),%edx
 56f:	89 55 10             	mov    %edx,0x10(%ebp)
 572:	85 c0                	test   %eax,%eax
 574:	7f dc                	jg     552 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 576:	8b 45 08             	mov    0x8(%ebp),%eax
}
 579:	c9                   	leave  
 57a:	c3                   	ret    

0000057b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 57b:	b8 01 00 00 00       	mov    $0x1,%eax
 580:	cd 40                	int    $0x40
 582:	c3                   	ret    

00000583 <exit>:
SYSCALL(exit)
 583:	b8 02 00 00 00       	mov    $0x2,%eax
 588:	cd 40                	int    $0x40
 58a:	c3                   	ret    

0000058b <wait>:
SYSCALL(wait)
 58b:	b8 03 00 00 00       	mov    $0x3,%eax
 590:	cd 40                	int    $0x40
 592:	c3                   	ret    

00000593 <pipe>:
SYSCALL(pipe)
 593:	b8 04 00 00 00       	mov    $0x4,%eax
 598:	cd 40                	int    $0x40
 59a:	c3                   	ret    

0000059b <read>:
SYSCALL(read)
 59b:	b8 05 00 00 00       	mov    $0x5,%eax
 5a0:	cd 40                	int    $0x40
 5a2:	c3                   	ret    

000005a3 <write>:
SYSCALL(write)
 5a3:	b8 10 00 00 00       	mov    $0x10,%eax
 5a8:	cd 40                	int    $0x40
 5aa:	c3                   	ret    

000005ab <close>:
SYSCALL(close)
 5ab:	b8 15 00 00 00       	mov    $0x15,%eax
 5b0:	cd 40                	int    $0x40
 5b2:	c3                   	ret    

000005b3 <kill>:
SYSCALL(kill)
 5b3:	b8 06 00 00 00       	mov    $0x6,%eax
 5b8:	cd 40                	int    $0x40
 5ba:	c3                   	ret    

000005bb <exec>:
SYSCALL(exec)
 5bb:	b8 07 00 00 00       	mov    $0x7,%eax
 5c0:	cd 40                	int    $0x40
 5c2:	c3                   	ret    

000005c3 <open>:
SYSCALL(open)
 5c3:	b8 0f 00 00 00       	mov    $0xf,%eax
 5c8:	cd 40                	int    $0x40
 5ca:	c3                   	ret    

000005cb <mknod>:
SYSCALL(mknod)
 5cb:	b8 11 00 00 00       	mov    $0x11,%eax
 5d0:	cd 40                	int    $0x40
 5d2:	c3                   	ret    

000005d3 <unlink>:
SYSCALL(unlink)
 5d3:	b8 12 00 00 00       	mov    $0x12,%eax
 5d8:	cd 40                	int    $0x40
 5da:	c3                   	ret    

000005db <fstat>:
SYSCALL(fstat)
 5db:	b8 08 00 00 00       	mov    $0x8,%eax
 5e0:	cd 40                	int    $0x40
 5e2:	c3                   	ret    

000005e3 <link>:
SYSCALL(link)
 5e3:	b8 13 00 00 00       	mov    $0x13,%eax
 5e8:	cd 40                	int    $0x40
 5ea:	c3                   	ret    

000005eb <mkdir>:
SYSCALL(mkdir)
 5eb:	b8 14 00 00 00       	mov    $0x14,%eax
 5f0:	cd 40                	int    $0x40
 5f2:	c3                   	ret    

000005f3 <chdir>:
SYSCALL(chdir)
 5f3:	b8 09 00 00 00       	mov    $0x9,%eax
 5f8:	cd 40                	int    $0x40
 5fa:	c3                   	ret    

000005fb <dup>:
SYSCALL(dup)
 5fb:	b8 0a 00 00 00       	mov    $0xa,%eax
 600:	cd 40                	int    $0x40
 602:	c3                   	ret    

00000603 <getpid>:
SYSCALL(getpid)
 603:	b8 0b 00 00 00       	mov    $0xb,%eax
 608:	cd 40                	int    $0x40
 60a:	c3                   	ret    

0000060b <sbrk>:
SYSCALL(sbrk)
 60b:	b8 0c 00 00 00       	mov    $0xc,%eax
 610:	cd 40                	int    $0x40
 612:	c3                   	ret    

00000613 <sleep>:
SYSCALL(sleep)
 613:	b8 0d 00 00 00       	mov    $0xd,%eax
 618:	cd 40                	int    $0x40
 61a:	c3                   	ret    

0000061b <uptime>:
SYSCALL(uptime)
 61b:	b8 0e 00 00 00       	mov    $0xe,%eax
 620:	cd 40                	int    $0x40
 622:	c3                   	ret    

00000623 <halt>:
SYSCALL(halt)
 623:	b8 16 00 00 00       	mov    $0x16,%eax
 628:	cd 40                	int    $0x40
 62a:	c3                   	ret    

0000062b <date>:
SYSCALL(date)
 62b:	b8 17 00 00 00       	mov    $0x17,%eax
 630:	cd 40                	int    $0x40
 632:	c3                   	ret    

00000633 <getuid>:
SYSCALL(getuid)
 633:	b8 18 00 00 00       	mov    $0x18,%eax
 638:	cd 40                	int    $0x40
 63a:	c3                   	ret    

0000063b <getgid>:
SYSCALL(getgid)
 63b:	b8 19 00 00 00       	mov    $0x19,%eax
 640:	cd 40                	int    $0x40
 642:	c3                   	ret    

00000643 <getppid>:
SYSCALL(getppid)
 643:	b8 1a 00 00 00       	mov    $0x1a,%eax
 648:	cd 40                	int    $0x40
 64a:	c3                   	ret    

0000064b <setuid>:
SYSCALL(setuid)
 64b:	b8 1b 00 00 00       	mov    $0x1b,%eax
 650:	cd 40                	int    $0x40
 652:	c3                   	ret    

00000653 <setgid>:
SYSCALL(setgid)
 653:	b8 1c 00 00 00       	mov    $0x1c,%eax
 658:	cd 40                	int    $0x40
 65a:	c3                   	ret    

0000065b <getprocs>:
SYSCALL(getprocs)
 65b:	b8 1d 00 00 00       	mov    $0x1d,%eax
 660:	cd 40                	int    $0x40
 662:	c3                   	ret    

00000663 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 663:	55                   	push   %ebp
 664:	89 e5                	mov    %esp,%ebp
 666:	83 ec 18             	sub    $0x18,%esp
 669:	8b 45 0c             	mov    0xc(%ebp),%eax
 66c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 66f:	83 ec 04             	sub    $0x4,%esp
 672:	6a 01                	push   $0x1
 674:	8d 45 f4             	lea    -0xc(%ebp),%eax
 677:	50                   	push   %eax
 678:	ff 75 08             	pushl  0x8(%ebp)
 67b:	e8 23 ff ff ff       	call   5a3 <write>
 680:	83 c4 10             	add    $0x10,%esp
}
 683:	90                   	nop
 684:	c9                   	leave  
 685:	c3                   	ret    

00000686 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 686:	55                   	push   %ebp
 687:	89 e5                	mov    %esp,%ebp
 689:	53                   	push   %ebx
 68a:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 68d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 694:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 698:	74 17                	je     6b1 <printint+0x2b>
 69a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 69e:	79 11                	jns    6b1 <printint+0x2b>
    neg = 1;
 6a0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6aa:	f7 d8                	neg    %eax
 6ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6af:	eb 06                	jmp    6b7 <printint+0x31>
  } else {
    x = xx;
 6b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6be:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6c1:	8d 41 01             	lea    0x1(%ecx),%eax
 6c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6cd:	ba 00 00 00 00       	mov    $0x0,%edx
 6d2:	f7 f3                	div    %ebx
 6d4:	89 d0                	mov    %edx,%eax
 6d6:	0f b6 80 d8 0d 00 00 	movzbl 0xdd8(%eax),%eax
 6dd:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e7:	ba 00 00 00 00       	mov    $0x0,%edx
 6ec:	f7 f3                	div    %ebx
 6ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6f5:	75 c7                	jne    6be <printint+0x38>
  if(neg)
 6f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6fb:	74 2d                	je     72a <printint+0xa4>
    buf[i++] = '-';
 6fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 700:	8d 50 01             	lea    0x1(%eax),%edx
 703:	89 55 f4             	mov    %edx,-0xc(%ebp)
 706:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 70b:	eb 1d                	jmp    72a <printint+0xa4>
    putc(fd, buf[i]);
 70d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 710:	8b 45 f4             	mov    -0xc(%ebp),%eax
 713:	01 d0                	add    %edx,%eax
 715:	0f b6 00             	movzbl (%eax),%eax
 718:	0f be c0             	movsbl %al,%eax
 71b:	83 ec 08             	sub    $0x8,%esp
 71e:	50                   	push   %eax
 71f:	ff 75 08             	pushl  0x8(%ebp)
 722:	e8 3c ff ff ff       	call   663 <putc>
 727:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 72a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 72e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 732:	79 d9                	jns    70d <printint+0x87>
    putc(fd, buf[i]);
}
 734:	90                   	nop
 735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 738:	c9                   	leave  
 739:	c3                   	ret    

0000073a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 73a:	55                   	push   %ebp
 73b:	89 e5                	mov    %esp,%ebp
 73d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 740:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 747:	8d 45 0c             	lea    0xc(%ebp),%eax
 74a:	83 c0 04             	add    $0x4,%eax
 74d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 750:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 757:	e9 59 01 00 00       	jmp    8b5 <printf+0x17b>
    c = fmt[i] & 0xff;
 75c:	8b 55 0c             	mov    0xc(%ebp),%edx
 75f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 762:	01 d0                	add    %edx,%eax
 764:	0f b6 00             	movzbl (%eax),%eax
 767:	0f be c0             	movsbl %al,%eax
 76a:	25 ff 00 00 00       	and    $0xff,%eax
 76f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 772:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 776:	75 2c                	jne    7a4 <printf+0x6a>
      if(c == '%'){
 778:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 77c:	75 0c                	jne    78a <printf+0x50>
        state = '%';
 77e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 785:	e9 27 01 00 00       	jmp    8b1 <printf+0x177>
      } else {
        putc(fd, c);
 78a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 78d:	0f be c0             	movsbl %al,%eax
 790:	83 ec 08             	sub    $0x8,%esp
 793:	50                   	push   %eax
 794:	ff 75 08             	pushl  0x8(%ebp)
 797:	e8 c7 fe ff ff       	call   663 <putc>
 79c:	83 c4 10             	add    $0x10,%esp
 79f:	e9 0d 01 00 00       	jmp    8b1 <printf+0x177>
      }
    } else if(state == '%'){
 7a4:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7a8:	0f 85 03 01 00 00    	jne    8b1 <printf+0x177>
      if(c == 'd'){
 7ae:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7b2:	75 1e                	jne    7d2 <printf+0x98>
        printint(fd, *ap, 10, 1);
 7b4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7b7:	8b 00                	mov    (%eax),%eax
 7b9:	6a 01                	push   $0x1
 7bb:	6a 0a                	push   $0xa
 7bd:	50                   	push   %eax
 7be:	ff 75 08             	pushl  0x8(%ebp)
 7c1:	e8 c0 fe ff ff       	call   686 <printint>
 7c6:	83 c4 10             	add    $0x10,%esp
        ap++;
 7c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7cd:	e9 d8 00 00 00       	jmp    8aa <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 7d2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7d6:	74 06                	je     7de <printf+0xa4>
 7d8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 7dc:	75 1e                	jne    7fc <printf+0xc2>
        printint(fd, *ap, 16, 0);
 7de:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7e1:	8b 00                	mov    (%eax),%eax
 7e3:	6a 00                	push   $0x0
 7e5:	6a 10                	push   $0x10
 7e7:	50                   	push   %eax
 7e8:	ff 75 08             	pushl  0x8(%ebp)
 7eb:	e8 96 fe ff ff       	call   686 <printint>
 7f0:	83 c4 10             	add    $0x10,%esp
        ap++;
 7f3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f7:	e9 ae 00 00 00       	jmp    8aa <printf+0x170>
      } else if(c == 's'){
 7fc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 800:	75 43                	jne    845 <printf+0x10b>
        s = (char*)*ap;
 802:	8b 45 e8             	mov    -0x18(%ebp),%eax
 805:	8b 00                	mov    (%eax),%eax
 807:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 80a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 80e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 812:	75 25                	jne    839 <printf+0xff>
          s = "(null)";
 814:	c7 45 f4 44 0b 00 00 	movl   $0xb44,-0xc(%ebp)
        while(*s != 0){
 81b:	eb 1c                	jmp    839 <printf+0xff>
          putc(fd, *s);
 81d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 820:	0f b6 00             	movzbl (%eax),%eax
 823:	0f be c0             	movsbl %al,%eax
 826:	83 ec 08             	sub    $0x8,%esp
 829:	50                   	push   %eax
 82a:	ff 75 08             	pushl  0x8(%ebp)
 82d:	e8 31 fe ff ff       	call   663 <putc>
 832:	83 c4 10             	add    $0x10,%esp
          s++;
 835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	0f b6 00             	movzbl (%eax),%eax
 83f:	84 c0                	test   %al,%al
 841:	75 da                	jne    81d <printf+0xe3>
 843:	eb 65                	jmp    8aa <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 845:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 849:	75 1d                	jne    868 <printf+0x12e>
        putc(fd, *ap);
 84b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 84e:	8b 00                	mov    (%eax),%eax
 850:	0f be c0             	movsbl %al,%eax
 853:	83 ec 08             	sub    $0x8,%esp
 856:	50                   	push   %eax
 857:	ff 75 08             	pushl  0x8(%ebp)
 85a:	e8 04 fe ff ff       	call   663 <putc>
 85f:	83 c4 10             	add    $0x10,%esp
        ap++;
 862:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 866:	eb 42                	jmp    8aa <printf+0x170>
      } else if(c == '%'){
 868:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 86c:	75 17                	jne    885 <printf+0x14b>
        putc(fd, c);
 86e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 871:	0f be c0             	movsbl %al,%eax
 874:	83 ec 08             	sub    $0x8,%esp
 877:	50                   	push   %eax
 878:	ff 75 08             	pushl  0x8(%ebp)
 87b:	e8 e3 fd ff ff       	call   663 <putc>
 880:	83 c4 10             	add    $0x10,%esp
 883:	eb 25                	jmp    8aa <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 885:	83 ec 08             	sub    $0x8,%esp
 888:	6a 25                	push   $0x25
 88a:	ff 75 08             	pushl  0x8(%ebp)
 88d:	e8 d1 fd ff ff       	call   663 <putc>
 892:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 895:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 898:	0f be c0             	movsbl %al,%eax
 89b:	83 ec 08             	sub    $0x8,%esp
 89e:	50                   	push   %eax
 89f:	ff 75 08             	pushl  0x8(%ebp)
 8a2:	e8 bc fd ff ff       	call   663 <putc>
 8a7:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 8aa:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8b1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 8b5:	8b 55 0c             	mov    0xc(%ebp),%edx
 8b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8bb:	01 d0                	add    %edx,%eax
 8bd:	0f b6 00             	movzbl (%eax),%eax
 8c0:	84 c0                	test   %al,%al
 8c2:	0f 85 94 fe ff ff    	jne    75c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 8c8:	90                   	nop
 8c9:	c9                   	leave  
 8ca:	c3                   	ret    

000008cb <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8cb:	55                   	push   %ebp
 8cc:	89 e5                	mov    %esp,%ebp
 8ce:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d1:	8b 45 08             	mov    0x8(%ebp),%eax
 8d4:	83 e8 08             	sub    $0x8,%eax
 8d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8da:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 8df:	89 45 fc             	mov    %eax,-0x4(%ebp)
 8e2:	eb 24                	jmp    908 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e7:	8b 00                	mov    (%eax),%eax
 8e9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8ec:	77 12                	ja     900 <free+0x35>
 8ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 8f4:	77 24                	ja     91a <free+0x4f>
 8f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f9:	8b 00                	mov    (%eax),%eax
 8fb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 8fe:	77 1a                	ja     91a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 900:	8b 45 fc             	mov    -0x4(%ebp),%eax
 903:	8b 00                	mov    (%eax),%eax
 905:	89 45 fc             	mov    %eax,-0x4(%ebp)
 908:	8b 45 f8             	mov    -0x8(%ebp),%eax
 90b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 90e:	76 d4                	jbe    8e4 <free+0x19>
 910:	8b 45 fc             	mov    -0x4(%ebp),%eax
 913:	8b 00                	mov    (%eax),%eax
 915:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 918:	76 ca                	jbe    8e4 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 91a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 91d:	8b 40 04             	mov    0x4(%eax),%eax
 920:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 927:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92a:	01 c2                	add    %eax,%edx
 92c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 92f:	8b 00                	mov    (%eax),%eax
 931:	39 c2                	cmp    %eax,%edx
 933:	75 24                	jne    959 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 935:	8b 45 f8             	mov    -0x8(%ebp),%eax
 938:	8b 50 04             	mov    0x4(%eax),%edx
 93b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93e:	8b 00                	mov    (%eax),%eax
 940:	8b 40 04             	mov    0x4(%eax),%eax
 943:	01 c2                	add    %eax,%edx
 945:	8b 45 f8             	mov    -0x8(%ebp),%eax
 948:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 94b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94e:	8b 00                	mov    (%eax),%eax
 950:	8b 10                	mov    (%eax),%edx
 952:	8b 45 f8             	mov    -0x8(%ebp),%eax
 955:	89 10                	mov    %edx,(%eax)
 957:	eb 0a                	jmp    963 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 959:	8b 45 fc             	mov    -0x4(%ebp),%eax
 95c:	8b 10                	mov    (%eax),%edx
 95e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 961:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 963:	8b 45 fc             	mov    -0x4(%ebp),%eax
 966:	8b 40 04             	mov    0x4(%eax),%eax
 969:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 970:	8b 45 fc             	mov    -0x4(%ebp),%eax
 973:	01 d0                	add    %edx,%eax
 975:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 978:	75 20                	jne    99a <free+0xcf>
    p->s.size += bp->s.size;
 97a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 97d:	8b 50 04             	mov    0x4(%eax),%edx
 980:	8b 45 f8             	mov    -0x8(%ebp),%eax
 983:	8b 40 04             	mov    0x4(%eax),%eax
 986:	01 c2                	add    %eax,%edx
 988:	8b 45 fc             	mov    -0x4(%ebp),%eax
 98b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 98e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 991:	8b 10                	mov    (%eax),%edx
 993:	8b 45 fc             	mov    -0x4(%ebp),%eax
 996:	89 10                	mov    %edx,(%eax)
 998:	eb 08                	jmp    9a2 <free+0xd7>
  } else
    p->s.ptr = bp;
 99a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9a0:	89 10                	mov    %edx,(%eax)
  freep = p;
 9a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9a5:	a3 f4 0d 00 00       	mov    %eax,0xdf4
}
 9aa:	90                   	nop
 9ab:	c9                   	leave  
 9ac:	c3                   	ret    

000009ad <morecore>:

static Header*
morecore(uint nu)
{
 9ad:	55                   	push   %ebp
 9ae:	89 e5                	mov    %esp,%ebp
 9b0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9b3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9ba:	77 07                	ja     9c3 <morecore+0x16>
    nu = 4096;
 9bc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9c3:	8b 45 08             	mov    0x8(%ebp),%eax
 9c6:	c1 e0 03             	shl    $0x3,%eax
 9c9:	83 ec 0c             	sub    $0xc,%esp
 9cc:	50                   	push   %eax
 9cd:	e8 39 fc ff ff       	call   60b <sbrk>
 9d2:	83 c4 10             	add    $0x10,%esp
 9d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 9d8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 9dc:	75 07                	jne    9e5 <morecore+0x38>
    return 0;
 9de:	b8 00 00 00 00       	mov    $0x0,%eax
 9e3:	eb 26                	jmp    a0b <morecore+0x5e>
  hp = (Header*)p;
 9e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 9eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ee:	8b 55 08             	mov    0x8(%ebp),%edx
 9f1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 9f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f7:	83 c0 08             	add    $0x8,%eax
 9fa:	83 ec 0c             	sub    $0xc,%esp
 9fd:	50                   	push   %eax
 9fe:	e8 c8 fe ff ff       	call   8cb <free>
 a03:	83 c4 10             	add    $0x10,%esp
  return freep;
 a06:	a1 f4 0d 00 00       	mov    0xdf4,%eax
}
 a0b:	c9                   	leave  
 a0c:	c3                   	ret    

00000a0d <malloc>:

void*
malloc(uint nbytes)
{
 a0d:	55                   	push   %ebp
 a0e:	89 e5                	mov    %esp,%ebp
 a10:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a13:	8b 45 08             	mov    0x8(%ebp),%eax
 a16:	83 c0 07             	add    $0x7,%eax
 a19:	c1 e8 03             	shr    $0x3,%eax
 a1c:	83 c0 01             	add    $0x1,%eax
 a1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a22:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 a27:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a2e:	75 23                	jne    a53 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 a30:	c7 45 f0 ec 0d 00 00 	movl   $0xdec,-0x10(%ebp)
 a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a3a:	a3 f4 0d 00 00       	mov    %eax,0xdf4
 a3f:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 a44:	a3 ec 0d 00 00       	mov    %eax,0xdec
    base.s.size = 0;
 a49:	c7 05 f0 0d 00 00 00 	movl   $0x0,0xdf0
 a50:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a56:	8b 00                	mov    (%eax),%eax
 a58:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5e:	8b 40 04             	mov    0x4(%eax),%eax
 a61:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a64:	72 4d                	jb     ab3 <malloc+0xa6>
      if(p->s.size == nunits)
 a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a69:	8b 40 04             	mov    0x4(%eax),%eax
 a6c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a6f:	75 0c                	jne    a7d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a74:	8b 10                	mov    (%eax),%edx
 a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a79:	89 10                	mov    %edx,(%eax)
 a7b:	eb 26                	jmp    aa3 <malloc+0x96>
      else {
        p->s.size -= nunits;
 a7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a80:	8b 40 04             	mov    0x4(%eax),%eax
 a83:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a86:	89 c2                	mov    %eax,%edx
 a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a91:	8b 40 04             	mov    0x4(%eax),%eax
 a94:	c1 e0 03             	shl    $0x3,%eax
 a97:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a9d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 aa0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa6:	a3 f4 0d 00 00       	mov    %eax,0xdf4
      return (void*)(p + 1);
 aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aae:	83 c0 08             	add    $0x8,%eax
 ab1:	eb 3b                	jmp    aee <malloc+0xe1>
    }
    if(p == freep)
 ab3:	a1 f4 0d 00 00       	mov    0xdf4,%eax
 ab8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 abb:	75 1e                	jne    adb <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 abd:	83 ec 0c             	sub    $0xc,%esp
 ac0:	ff 75 ec             	pushl  -0x14(%ebp)
 ac3:	e8 e5 fe ff ff       	call   9ad <morecore>
 ac8:	83 c4 10             	add    $0x10,%esp
 acb:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ace:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ad2:	75 07                	jne    adb <malloc+0xce>
        return 0;
 ad4:	b8 00 00 00 00       	mov    $0x0,%eax
 ad9:	eb 13                	jmp    aee <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ade:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae4:	8b 00                	mov    (%eax),%eax
 ae6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ae9:	e9 6d ff ff ff       	jmp    a5b <malloc+0x4e>
}
 aee:	c9                   	leave  
 aef:	c3                   	ret    
