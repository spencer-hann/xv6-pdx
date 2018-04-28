
_testuidgid:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "user.h"

int
main(int argc, char* argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 24             	sub    $0x24,%esp
  uint uid, gid, ppid;
  int flag, errors = 0;
  11:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

//UID tests:
  uid = getuid();
  18:	e8 94 06 00 00       	call   6b1 <getuid>
  1d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(2, "Current UID is: %d\n", uid);
  20:	83 ec 04             	sub    $0x4,%esp
  23:	ff 75 f0             	pushl  -0x10(%ebp)
  26:	68 70 0b 00 00       	push   $0xb70
  2b:	6a 02                	push   $0x2
  2d:	e8 86 07 00 00       	call   7b8 <printf>
  32:	83 c4 10             	add    $0x10,%esp
  printf(2, "Setting UID to 100\n");
  35:	83 ec 08             	sub    $0x8,%esp
  38:	68 84 0b 00 00       	push   $0xb84
  3d:	6a 02                	push   $0x2
  3f:	e8 74 07 00 00       	call   7b8 <printf>
  44:	83 c4 10             	add    $0x10,%esp
  flag = setuid(100);
  47:	83 ec 0c             	sub    $0xc,%esp
  4a:	6a 64                	push   $0x64
  4c:	e8 78 06 00 00       	call   6c9 <setuid>
  51:	83 c4 10             	add    $0x10,%esp
  54:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uid = getuid();
  57:	e8 55 06 00 00       	call   6b1 <getuid>
  5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(2, "Current UID is: %d\n\n", uid);
  5f:	83 ec 04             	sub    $0x4,%esp
  62:	ff 75 f0             	pushl  -0x10(%ebp)
  65:	68 98 0b 00 00       	push   $0xb98
  6a:	6a 02                	push   $0x2
  6c:	e8 47 07 00 00       	call   7b8 <printf>
  71:	83 c4 10             	add    $0x10,%esp
  if (flag == -1 || uid != 100) {
  74:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
  78:	74 06                	je     80 <main+0x80>
  7a:	83 7d f0 64          	cmpl   $0x64,-0x10(%ebp)
  7e:	74 16                	je     96 <main+0x96>
    printf(2, "setuid failed\n\n");
  80:	83 ec 08             	sub    $0x8,%esp
  83:	68 ad 0b 00 00       	push   $0xbad
  88:	6a 02                	push   $0x2
  8a:	e8 29 07 00 00       	call   7b8 <printf>
  8f:	83 c4 10             	add    $0x10,%esp
    ++errors;
  92:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }

  printf(2, "Setting UID to invalid 100000\n");
  96:	83 ec 08             	sub    $0x8,%esp
  99:	68 c0 0b 00 00       	push   $0xbc0
  9e:	6a 02                	push   $0x2
  a0:	e8 13 07 00 00       	call   7b8 <printf>
  a5:	83 c4 10             	add    $0x10,%esp
  flag = setuid(100000);
  a8:	83 ec 0c             	sub    $0xc,%esp
  ab:	68 a0 86 01 00       	push   $0x186a0
  b0:	e8 14 06 00 00       	call   6c9 <setuid>
  b5:	83 c4 10             	add    $0x10,%esp
  b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uid = getuid();
  bb:	e8 f1 05 00 00       	call   6b1 <getuid>
  c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(2, "Current UID is: %d\n\n", uid);
  c3:	83 ec 04             	sub    $0x4,%esp
  c6:	ff 75 f0             	pushl  -0x10(%ebp)
  c9:	68 98 0b 00 00       	push   $0xb98
  ce:	6a 02                	push   $0x2
  d0:	e8 e3 06 00 00       	call   7b8 <printf>
  d5:	83 c4 10             	add    $0x10,%esp
  if (flag == -1)
  d8:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
  dc:	75 14                	jne    f2 <main+0xf2>
    printf(2, "setuid failed (good)\n\n");
  de:	83 ec 08             	sub    $0x8,%esp
  e1:	68 df 0b 00 00       	push   $0xbdf
  e6:	6a 02                	push   $0x2
  e8:	e8 cb 06 00 00       	call   7b8 <printf>
  ed:	83 c4 10             	add    $0x10,%esp
  f0:	eb 04                	jmp    f6 <main+0xf6>
  else
    ++errors;
  f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  printf(2, "Setting UID to invalid -1\n");
  f6:	83 ec 08             	sub    $0x8,%esp
  f9:	68 f6 0b 00 00       	push   $0xbf6
  fe:	6a 02                	push   $0x2
 100:	e8 b3 06 00 00       	call   7b8 <printf>
 105:	83 c4 10             	add    $0x10,%esp
  flag = setuid(-1);
 108:	83 ec 0c             	sub    $0xc,%esp
 10b:	6a ff                	push   $0xffffffff
 10d:	e8 b7 05 00 00       	call   6c9 <setuid>
 112:	83 c4 10             	add    $0x10,%esp
 115:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uid = getuid();
 118:	e8 94 05 00 00       	call   6b1 <getuid>
 11d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(2, "Current UID is: %d\n\n", uid);
 120:	83 ec 04             	sub    $0x4,%esp
 123:	ff 75 f0             	pushl  -0x10(%ebp)
 126:	68 98 0b 00 00       	push   $0xb98
 12b:	6a 02                	push   $0x2
 12d:	e8 86 06 00 00       	call   7b8 <printf>
 132:	83 c4 10             	add    $0x10,%esp
  if (flag == -1)
 135:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
 139:	75 14                	jne    14f <main+0x14f>
    printf(2, "setuid failed (good)\n\n");
 13b:	83 ec 08             	sub    $0x8,%esp
 13e:	68 df 0b 00 00       	push   $0xbdf
 143:	6a 02                	push   $0x2
 145:	e8 6e 06 00 00       	call   7b8 <printf>
 14a:	83 c4 10             	add    $0x10,%esp
 14d:	eb 04                	jmp    153 <main+0x153>
  else
    ++errors;
 14f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

// GID tests:
  gid = getgid();
 153:	e8 61 05 00 00       	call   6b9 <getgid>
 158:	89 45 e8             	mov    %eax,-0x18(%ebp)
  printf(2, "Current GID is: %d\n", gid);
 15b:	83 ec 04             	sub    $0x4,%esp
 15e:	ff 75 e8             	pushl  -0x18(%ebp)
 161:	68 11 0c 00 00       	push   $0xc11
 166:	6a 02                	push   $0x2
 168:	e8 4b 06 00 00       	call   7b8 <printf>
 16d:	83 c4 10             	add    $0x10,%esp
  printf(2, "Setting GID to 100\n");
 170:	83 ec 08             	sub    $0x8,%esp
 173:	68 25 0c 00 00       	push   $0xc25
 178:	6a 02                	push   $0x2
 17a:	e8 39 06 00 00       	call   7b8 <printf>
 17f:	83 c4 10             	add    $0x10,%esp
  flag = setgid(100);
 182:	83 ec 0c             	sub    $0xc,%esp
 185:	6a 64                	push   $0x64
 187:	e8 45 05 00 00       	call   6d1 <setgid>
 18c:	83 c4 10             	add    $0x10,%esp
 18f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  gid = getgid();
 192:	e8 22 05 00 00       	call   6b9 <getgid>
 197:	89 45 e8             	mov    %eax,-0x18(%ebp)
  printf(2, "Current GID is: %d\n\n", gid);
 19a:	83 ec 04             	sub    $0x4,%esp
 19d:	ff 75 e8             	pushl  -0x18(%ebp)
 1a0:	68 39 0c 00 00       	push   $0xc39
 1a5:	6a 02                	push   $0x2
 1a7:	e8 0c 06 00 00       	call   7b8 <printf>
 1ac:	83 c4 10             	add    $0x10,%esp
  if (flag == -1 || gid != 100) {
 1af:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
 1b3:	74 06                	je     1bb <main+0x1bb>
 1b5:	83 7d e8 64          	cmpl   $0x64,-0x18(%ebp)
 1b9:	74 16                	je     1d1 <main+0x1d1>
    printf(2, "setgid failed\n\n");
 1bb:	83 ec 08             	sub    $0x8,%esp
 1be:	68 4e 0c 00 00       	push   $0xc4e
 1c3:	6a 02                	push   $0x2
 1c5:	e8 ee 05 00 00       	call   7b8 <printf>
 1ca:	83 c4 10             	add    $0x10,%esp
     ++errors;
 1cd:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  }

  printf(2, "Setting GID to invalid 100000\n");
 1d1:	83 ec 08             	sub    $0x8,%esp
 1d4:	68 60 0c 00 00       	push   $0xc60
 1d9:	6a 02                	push   $0x2
 1db:	e8 d8 05 00 00       	call   7b8 <printf>
 1e0:	83 c4 10             	add    $0x10,%esp
  flag = setgid(100000);
 1e3:	83 ec 0c             	sub    $0xc,%esp
 1e6:	68 a0 86 01 00       	push   $0x186a0
 1eb:	e8 e1 04 00 00       	call   6d1 <setgid>
 1f0:	83 c4 10             	add    $0x10,%esp
 1f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  gid = getgid();
 1f6:	e8 be 04 00 00       	call   6b9 <getgid>
 1fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  printf(2, "Current GID is: %d\n\n", gid);
 1fe:	83 ec 04             	sub    $0x4,%esp
 201:	ff 75 e8             	pushl  -0x18(%ebp)
 204:	68 39 0c 00 00       	push   $0xc39
 209:	6a 02                	push   $0x2
 20b:	e8 a8 05 00 00       	call   7b8 <printf>
 210:	83 c4 10             	add    $0x10,%esp
  if (flag == -1)
 213:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
 217:	75 14                	jne    22d <main+0x22d>
    printf(2, "setgid failed (good)\n\n");
 219:	83 ec 08             	sub    $0x8,%esp
 21c:	68 7f 0c 00 00       	push   $0xc7f
 221:	6a 02                	push   $0x2
 223:	e8 90 05 00 00       	call   7b8 <printf>
 228:	83 c4 10             	add    $0x10,%esp
 22b:	eb 04                	jmp    231 <main+0x231>
  else
    ++errors;
 22d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

  printf(2, "Setting GID to invalid -1\n");
 231:	83 ec 08             	sub    $0x8,%esp
 234:	68 96 0c 00 00       	push   $0xc96
 239:	6a 02                	push   $0x2
 23b:	e8 78 05 00 00       	call   7b8 <printf>
 240:	83 c4 10             	add    $0x10,%esp
  flag = setgid(-1);
 243:	83 ec 0c             	sub    $0xc,%esp
 246:	6a ff                	push   $0xffffffff
 248:	e8 84 04 00 00       	call   6d1 <setgid>
 24d:	83 c4 10             	add    $0x10,%esp
 250:	89 45 ec             	mov    %eax,-0x14(%ebp)
  gid = getgid();
 253:	e8 61 04 00 00       	call   6b9 <getgid>
 258:	89 45 e8             	mov    %eax,-0x18(%ebp)
  printf(2, "Current GID is: %d\n\n", gid);
 25b:	83 ec 04             	sub    $0x4,%esp
 25e:	ff 75 e8             	pushl  -0x18(%ebp)
 261:	68 39 0c 00 00       	push   $0xc39
 266:	6a 02                	push   $0x2
 268:	e8 4b 05 00 00       	call   7b8 <printf>
 26d:	83 c4 10             	add    $0x10,%esp
  if (flag == -1)
 270:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
 274:	75 14                	jne    28a <main+0x28a>
    printf(2, "setgid failed (good)\n\n");
 276:	83 ec 08             	sub    $0x8,%esp
 279:	68 7f 0c 00 00       	push   $0xc7f
 27e:	6a 02                	push   $0x2
 280:	e8 33 05 00 00       	call   7b8 <printf>
 285:	83 c4 10             	add    $0x10,%esp
 288:	eb 04                	jmp    28e <main+0x28e>
  else
    ++errors;
 28a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

//PPID
  ppid = getppid();
 28e:	e8 2e 04 00 00       	call   6c1 <getppid>
 293:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  printf(2, "My PPID is: %d\n", ppid);
 296:	83 ec 04             	sub    $0x4,%esp
 299:	ff 75 e4             	pushl  -0x1c(%ebp)
 29c:	68 b1 0c 00 00       	push   $0xcb1
 2a1:	6a 02                	push   $0x2
 2a3:	e8 10 05 00 00       	call   7b8 <printf>
 2a8:	83 c4 10             	add    $0x10,%esp
  printf(2, "End of test.\n");
 2ab:	83 ec 08             	sub    $0x8,%esp
 2ae:	68 c1 0c 00 00       	push   $0xcc1
 2b3:	6a 02                	push   $0x2
 2b5:	e8 fe 04 00 00       	call   7b8 <printf>
 2ba:	83 c4 10             	add    $0x10,%esp

//Summary
  printf(2, "%d Errors.\n\n", errors);
 2bd:	83 ec 04             	sub    $0x4,%esp
 2c0:	ff 75 f4             	pushl  -0xc(%ebp)
 2c3:	68 cf 0c 00 00       	push   $0xccf
 2c8:	6a 02                	push   $0x2
 2ca:	e8 e9 04 00 00       	call   7b8 <printf>
 2cf:	83 c4 10             	add    $0x10,%esp
  exit();
 2d2:	e8 2a 03 00 00       	call   601 <exit>

000002d7 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 2d7:	55                   	push   %ebp
 2d8:	89 e5                	mov    %esp,%ebp
 2da:	57                   	push   %edi
 2db:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 2dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
 2df:	8b 55 10             	mov    0x10(%ebp),%edx
 2e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e5:	89 cb                	mov    %ecx,%ebx
 2e7:	89 df                	mov    %ebx,%edi
 2e9:	89 d1                	mov    %edx,%ecx
 2eb:	fc                   	cld    
 2ec:	f3 aa                	rep stos %al,%es:(%edi)
 2ee:	89 ca                	mov    %ecx,%edx
 2f0:	89 fb                	mov    %edi,%ebx
 2f2:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2f5:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2f8:	90                   	nop
 2f9:	5b                   	pop    %ebx
 2fa:	5f                   	pop    %edi
 2fb:	5d                   	pop    %ebp
 2fc:	c3                   	ret    

000002fd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 309:	90                   	nop
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	8d 50 01             	lea    0x1(%eax),%edx
 310:	89 55 08             	mov    %edx,0x8(%ebp)
 313:	8b 55 0c             	mov    0xc(%ebp),%edx
 316:	8d 4a 01             	lea    0x1(%edx),%ecx
 319:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 31c:	0f b6 12             	movzbl (%edx),%edx
 31f:	88 10                	mov    %dl,(%eax)
 321:	0f b6 00             	movzbl (%eax),%eax
 324:	84 c0                	test   %al,%al
 326:	75 e2                	jne    30a <strcpy+0xd>
    ;
  return os;
 328:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 32b:	c9                   	leave  
 32c:	c3                   	ret    

0000032d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 32d:	55                   	push   %ebp
 32e:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 330:	eb 08                	jmp    33a <strcmp+0xd>
    p++, q++;
 332:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 336:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 33a:	8b 45 08             	mov    0x8(%ebp),%eax
 33d:	0f b6 00             	movzbl (%eax),%eax
 340:	84 c0                	test   %al,%al
 342:	74 10                	je     354 <strcmp+0x27>
 344:	8b 45 08             	mov    0x8(%ebp),%eax
 347:	0f b6 10             	movzbl (%eax),%edx
 34a:	8b 45 0c             	mov    0xc(%ebp),%eax
 34d:	0f b6 00             	movzbl (%eax),%eax
 350:	38 c2                	cmp    %al,%dl
 352:	74 de                	je     332 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	0f b6 00             	movzbl (%eax),%eax
 35a:	0f b6 d0             	movzbl %al,%edx
 35d:	8b 45 0c             	mov    0xc(%ebp),%eax
 360:	0f b6 00             	movzbl (%eax),%eax
 363:	0f b6 c0             	movzbl %al,%eax
 366:	29 c2                	sub    %eax,%edx
 368:	89 d0                	mov    %edx,%eax
}
 36a:	5d                   	pop    %ebp
 36b:	c3                   	ret    

0000036c <strlen>:

uint
strlen(char *s)
{
 36c:	55                   	push   %ebp
 36d:	89 e5                	mov    %esp,%ebp
 36f:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 372:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 379:	eb 04                	jmp    37f <strlen+0x13>
 37b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 37f:	8b 55 fc             	mov    -0x4(%ebp),%edx
 382:	8b 45 08             	mov    0x8(%ebp),%eax
 385:	01 d0                	add    %edx,%eax
 387:	0f b6 00             	movzbl (%eax),%eax
 38a:	84 c0                	test   %al,%al
 38c:	75 ed                	jne    37b <strlen+0xf>
    ;
  return n;
 38e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 391:	c9                   	leave  
 392:	c3                   	ret    

00000393 <memset>:

void*
memset(void *dst, int c, uint n)
{
 393:	55                   	push   %ebp
 394:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 396:	8b 45 10             	mov    0x10(%ebp),%eax
 399:	50                   	push   %eax
 39a:	ff 75 0c             	pushl  0xc(%ebp)
 39d:	ff 75 08             	pushl  0x8(%ebp)
 3a0:	e8 32 ff ff ff       	call   2d7 <stosb>
 3a5:	83 c4 0c             	add    $0xc,%esp
  return dst;
 3a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3ab:	c9                   	leave  
 3ac:	c3                   	ret    

000003ad <strchr>:

char*
strchr(const char *s, char c)
{
 3ad:	55                   	push   %ebp
 3ae:	89 e5                	mov    %esp,%ebp
 3b0:	83 ec 04             	sub    $0x4,%esp
 3b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b6:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 3b9:	eb 14                	jmp    3cf <strchr+0x22>
    if(*s == c)
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	0f b6 00             	movzbl (%eax),%eax
 3c1:	3a 45 fc             	cmp    -0x4(%ebp),%al
 3c4:	75 05                	jne    3cb <strchr+0x1e>
      return (char*)s;
 3c6:	8b 45 08             	mov    0x8(%ebp),%eax
 3c9:	eb 13                	jmp    3de <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 3cb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3cf:	8b 45 08             	mov    0x8(%ebp),%eax
 3d2:	0f b6 00             	movzbl (%eax),%eax
 3d5:	84 c0                	test   %al,%al
 3d7:	75 e2                	jne    3bb <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 3d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3de:	c9                   	leave  
 3df:	c3                   	ret    

000003e0 <gets>:

char*
gets(char *buf, int max)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3ed:	eb 42                	jmp    431 <gets+0x51>
    cc = read(0, &c, 1);
 3ef:	83 ec 04             	sub    $0x4,%esp
 3f2:	6a 01                	push   $0x1
 3f4:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3f7:	50                   	push   %eax
 3f8:	6a 00                	push   $0x0
 3fa:	e8 1a 02 00 00       	call   619 <read>
 3ff:	83 c4 10             	add    $0x10,%esp
 402:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 405:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 409:	7e 33                	jle    43e <gets+0x5e>
      break;
    buf[i++] = c;
 40b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40e:	8d 50 01             	lea    0x1(%eax),%edx
 411:	89 55 f4             	mov    %edx,-0xc(%ebp)
 414:	89 c2                	mov    %eax,%edx
 416:	8b 45 08             	mov    0x8(%ebp),%eax
 419:	01 c2                	add    %eax,%edx
 41b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 41f:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 421:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 425:	3c 0a                	cmp    $0xa,%al
 427:	74 16                	je     43f <gets+0x5f>
 429:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 42d:	3c 0d                	cmp    $0xd,%al
 42f:	74 0e                	je     43f <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 431:	8b 45 f4             	mov    -0xc(%ebp),%eax
 434:	83 c0 01             	add    $0x1,%eax
 437:	3b 45 0c             	cmp    0xc(%ebp),%eax
 43a:	7c b3                	jl     3ef <gets+0xf>
 43c:	eb 01                	jmp    43f <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 43e:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 43f:	8b 55 f4             	mov    -0xc(%ebp),%edx
 442:	8b 45 08             	mov    0x8(%ebp),%eax
 445:	01 d0                	add    %edx,%eax
 447:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 44a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 44d:	c9                   	leave  
 44e:	c3                   	ret    

0000044f <stat>:

int
stat(char *n, struct stat *st)
{
 44f:	55                   	push   %ebp
 450:	89 e5                	mov    %esp,%ebp
 452:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 455:	83 ec 08             	sub    $0x8,%esp
 458:	6a 00                	push   $0x0
 45a:	ff 75 08             	pushl  0x8(%ebp)
 45d:	e8 df 01 00 00       	call   641 <open>
 462:	83 c4 10             	add    $0x10,%esp
 465:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 468:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 46c:	79 07                	jns    475 <stat+0x26>
    return -1;
 46e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 473:	eb 25                	jmp    49a <stat+0x4b>
  r = fstat(fd, st);
 475:	83 ec 08             	sub    $0x8,%esp
 478:	ff 75 0c             	pushl  0xc(%ebp)
 47b:	ff 75 f4             	pushl  -0xc(%ebp)
 47e:	e8 d6 01 00 00       	call   659 <fstat>
 483:	83 c4 10             	add    $0x10,%esp
 486:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 489:	83 ec 0c             	sub    $0xc,%esp
 48c:	ff 75 f4             	pushl  -0xc(%ebp)
 48f:	e8 95 01 00 00       	call   629 <close>
 494:	83 c4 10             	add    $0x10,%esp
  return r;
 497:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 49a:	c9                   	leave  
 49b:	c3                   	ret    

0000049c <atoi>:

int
atoi(const char *s)
{
 49c:	55                   	push   %ebp
 49d:	89 e5                	mov    %esp,%ebp
 49f:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 4a2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 4a9:	eb 04                	jmp    4af <atoi+0x13>
 4ab:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 4af:	8b 45 08             	mov    0x8(%ebp),%eax
 4b2:	0f b6 00             	movzbl (%eax),%eax
 4b5:	3c 20                	cmp    $0x20,%al
 4b7:	74 f2                	je     4ab <atoi+0xf>
  sign = (*s == '-') ? -1 : 1;
 4b9:	8b 45 08             	mov    0x8(%ebp),%eax
 4bc:	0f b6 00             	movzbl (%eax),%eax
 4bf:	3c 2d                	cmp    $0x2d,%al
 4c1:	75 07                	jne    4ca <atoi+0x2e>
 4c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4c8:	eb 05                	jmp    4cf <atoi+0x33>
 4ca:	b8 01 00 00 00       	mov    $0x1,%eax
 4cf:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 4d2:	8b 45 08             	mov    0x8(%ebp),%eax
 4d5:	0f b6 00             	movzbl (%eax),%eax
 4d8:	3c 2b                	cmp    $0x2b,%al
 4da:	74 0a                	je     4e6 <atoi+0x4a>
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	0f b6 00             	movzbl (%eax),%eax
 4e2:	3c 2d                	cmp    $0x2d,%al
 4e4:	75 2b                	jne    511 <atoi+0x75>
    s++;
 4e6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '9')
 4ea:	eb 25                	jmp    511 <atoi+0x75>
    n = n*10 + *s++ - '0';
 4ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4ef:	89 d0                	mov    %edx,%eax
 4f1:	c1 e0 02             	shl    $0x2,%eax
 4f4:	01 d0                	add    %edx,%eax
 4f6:	01 c0                	add    %eax,%eax
 4f8:	89 c1                	mov    %eax,%ecx
 4fa:	8b 45 08             	mov    0x8(%ebp),%eax
 4fd:	8d 50 01             	lea    0x1(%eax),%edx
 500:	89 55 08             	mov    %edx,0x8(%ebp)
 503:	0f b6 00             	movzbl (%eax),%eax
 506:	0f be c0             	movsbl %al,%eax
 509:	01 c8                	add    %ecx,%eax
 50b:	83 e8 30             	sub    $0x30,%eax
 50e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '9')
 511:	8b 45 08             	mov    0x8(%ebp),%eax
 514:	0f b6 00             	movzbl (%eax),%eax
 517:	3c 2f                	cmp    $0x2f,%al
 519:	7e 0a                	jle    525 <atoi+0x89>
 51b:	8b 45 08             	mov    0x8(%ebp),%eax
 51e:	0f b6 00             	movzbl (%eax),%eax
 521:	3c 39                	cmp    $0x39,%al
 523:	7e c7                	jle    4ec <atoi+0x50>
    n = n*10 + *s++ - '0';
  return sign*n;
 525:	8b 45 f8             	mov    -0x8(%ebp),%eax
 528:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 52c:	c9                   	leave  
 52d:	c3                   	ret    

0000052e <atoo>:

int
atoo(const char *s)
{
 52e:	55                   	push   %ebp
 52f:	89 e5                	mov    %esp,%ebp
 531:	83 ec 10             	sub    $0x10,%esp
  int n, sign;

  n = 0;
 534:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while (*s == ' ') s++;
 53b:	eb 04                	jmp    541 <atoo+0x13>
 53d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 541:	8b 45 08             	mov    0x8(%ebp),%eax
 544:	0f b6 00             	movzbl (%eax),%eax
 547:	3c 20                	cmp    $0x20,%al
 549:	74 f2                	je     53d <atoo+0xf>
  sign = (*s == '-') ? -1 : 1;
 54b:	8b 45 08             	mov    0x8(%ebp),%eax
 54e:	0f b6 00             	movzbl (%eax),%eax
 551:	3c 2d                	cmp    $0x2d,%al
 553:	75 07                	jne    55c <atoo+0x2e>
 555:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 55a:	eb 05                	jmp    561 <atoo+0x33>
 55c:	b8 01 00 00 00       	mov    $0x1,%eax
 561:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if (*s == '+'  || *s == '-')
 564:	8b 45 08             	mov    0x8(%ebp),%eax
 567:	0f b6 00             	movzbl (%eax),%eax
 56a:	3c 2b                	cmp    $0x2b,%al
 56c:	74 0a                	je     578 <atoo+0x4a>
 56e:	8b 45 08             	mov    0x8(%ebp),%eax
 571:	0f b6 00             	movzbl (%eax),%eax
 574:	3c 2d                	cmp    $0x2d,%al
 576:	75 27                	jne    59f <atoo+0x71>
    s++;
 578:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while('0' <= *s && *s <= '7')
 57c:	eb 21                	jmp    59f <atoo+0x71>
    n = n*8 + *s++ - '0';
 57e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 581:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
 588:	8b 45 08             	mov    0x8(%ebp),%eax
 58b:	8d 50 01             	lea    0x1(%eax),%edx
 58e:	89 55 08             	mov    %edx,0x8(%ebp)
 591:	0f b6 00             	movzbl (%eax),%eax
 594:	0f be c0             	movsbl %al,%eax
 597:	01 c8                	add    %ecx,%eax
 599:	83 e8 30             	sub    $0x30,%eax
 59c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  n = 0;
  while (*s == ' ') s++;
  sign = (*s == '-') ? -1 : 1;
  if (*s == '+'  || *s == '-')
    s++;
  while('0' <= *s && *s <= '7')
 59f:	8b 45 08             	mov    0x8(%ebp),%eax
 5a2:	0f b6 00             	movzbl (%eax),%eax
 5a5:	3c 2f                	cmp    $0x2f,%al
 5a7:	7e 0a                	jle    5b3 <atoo+0x85>
 5a9:	8b 45 08             	mov    0x8(%ebp),%eax
 5ac:	0f b6 00             	movzbl (%eax),%eax
 5af:	3c 37                	cmp    $0x37,%al
 5b1:	7e cb                	jle    57e <atoo+0x50>
    n = n*8 + *s++ - '0';
  return sign*n;
 5b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5b6:	0f af 45 fc          	imul   -0x4(%ebp),%eax
}
 5ba:	c9                   	leave  
 5bb:	c3                   	ret    

000005bc <memmove>:


void*
memmove(void *vdst, void *vsrc, int n)
{
 5bc:	55                   	push   %ebp
 5bd:	89 e5                	mov    %esp,%ebp
 5bf:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 5c2:	8b 45 08             	mov    0x8(%ebp),%eax
 5c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 5c8:	8b 45 0c             	mov    0xc(%ebp),%eax
 5cb:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 5ce:	eb 17                	jmp    5e7 <memmove+0x2b>
    *dst++ = *src++;
 5d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5d3:	8d 50 01             	lea    0x1(%eax),%edx
 5d6:	89 55 fc             	mov    %edx,-0x4(%ebp)
 5d9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 5dc:	8d 4a 01             	lea    0x1(%edx),%ecx
 5df:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 5e2:	0f b6 12             	movzbl (%edx),%edx
 5e5:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5e7:	8b 45 10             	mov    0x10(%ebp),%eax
 5ea:	8d 50 ff             	lea    -0x1(%eax),%edx
 5ed:	89 55 10             	mov    %edx,0x10(%ebp)
 5f0:	85 c0                	test   %eax,%eax
 5f2:	7f dc                	jg     5d0 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 5f4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 5f7:	c9                   	leave  
 5f8:	c3                   	ret    

000005f9 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5f9:	b8 01 00 00 00       	mov    $0x1,%eax
 5fe:	cd 40                	int    $0x40
 600:	c3                   	ret    

00000601 <exit>:
SYSCALL(exit)
 601:	b8 02 00 00 00       	mov    $0x2,%eax
 606:	cd 40                	int    $0x40
 608:	c3                   	ret    

00000609 <wait>:
SYSCALL(wait)
 609:	b8 03 00 00 00       	mov    $0x3,%eax
 60e:	cd 40                	int    $0x40
 610:	c3                   	ret    

00000611 <pipe>:
SYSCALL(pipe)
 611:	b8 04 00 00 00       	mov    $0x4,%eax
 616:	cd 40                	int    $0x40
 618:	c3                   	ret    

00000619 <read>:
SYSCALL(read)
 619:	b8 05 00 00 00       	mov    $0x5,%eax
 61e:	cd 40                	int    $0x40
 620:	c3                   	ret    

00000621 <write>:
SYSCALL(write)
 621:	b8 10 00 00 00       	mov    $0x10,%eax
 626:	cd 40                	int    $0x40
 628:	c3                   	ret    

00000629 <close>:
SYSCALL(close)
 629:	b8 15 00 00 00       	mov    $0x15,%eax
 62e:	cd 40                	int    $0x40
 630:	c3                   	ret    

00000631 <kill>:
SYSCALL(kill)
 631:	b8 06 00 00 00       	mov    $0x6,%eax
 636:	cd 40                	int    $0x40
 638:	c3                   	ret    

00000639 <exec>:
SYSCALL(exec)
 639:	b8 07 00 00 00       	mov    $0x7,%eax
 63e:	cd 40                	int    $0x40
 640:	c3                   	ret    

00000641 <open>:
SYSCALL(open)
 641:	b8 0f 00 00 00       	mov    $0xf,%eax
 646:	cd 40                	int    $0x40
 648:	c3                   	ret    

00000649 <mknod>:
SYSCALL(mknod)
 649:	b8 11 00 00 00       	mov    $0x11,%eax
 64e:	cd 40                	int    $0x40
 650:	c3                   	ret    

00000651 <unlink>:
SYSCALL(unlink)
 651:	b8 12 00 00 00       	mov    $0x12,%eax
 656:	cd 40                	int    $0x40
 658:	c3                   	ret    

00000659 <fstat>:
SYSCALL(fstat)
 659:	b8 08 00 00 00       	mov    $0x8,%eax
 65e:	cd 40                	int    $0x40
 660:	c3                   	ret    

00000661 <link>:
SYSCALL(link)
 661:	b8 13 00 00 00       	mov    $0x13,%eax
 666:	cd 40                	int    $0x40
 668:	c3                   	ret    

00000669 <mkdir>:
SYSCALL(mkdir)
 669:	b8 14 00 00 00       	mov    $0x14,%eax
 66e:	cd 40                	int    $0x40
 670:	c3                   	ret    

00000671 <chdir>:
SYSCALL(chdir)
 671:	b8 09 00 00 00       	mov    $0x9,%eax
 676:	cd 40                	int    $0x40
 678:	c3                   	ret    

00000679 <dup>:
SYSCALL(dup)
 679:	b8 0a 00 00 00       	mov    $0xa,%eax
 67e:	cd 40                	int    $0x40
 680:	c3                   	ret    

00000681 <getpid>:
SYSCALL(getpid)
 681:	b8 0b 00 00 00       	mov    $0xb,%eax
 686:	cd 40                	int    $0x40
 688:	c3                   	ret    

00000689 <sbrk>:
SYSCALL(sbrk)
 689:	b8 0c 00 00 00       	mov    $0xc,%eax
 68e:	cd 40                	int    $0x40
 690:	c3                   	ret    

00000691 <sleep>:
SYSCALL(sleep)
 691:	b8 0d 00 00 00       	mov    $0xd,%eax
 696:	cd 40                	int    $0x40
 698:	c3                   	ret    

00000699 <uptime>:
SYSCALL(uptime)
 699:	b8 0e 00 00 00       	mov    $0xe,%eax
 69e:	cd 40                	int    $0x40
 6a0:	c3                   	ret    

000006a1 <halt>:
SYSCALL(halt)
 6a1:	b8 16 00 00 00       	mov    $0x16,%eax
 6a6:	cd 40                	int    $0x40
 6a8:	c3                   	ret    

000006a9 <date>:
SYSCALL(date)
 6a9:	b8 17 00 00 00       	mov    $0x17,%eax
 6ae:	cd 40                	int    $0x40
 6b0:	c3                   	ret    

000006b1 <getuid>:
SYSCALL(getuid)
 6b1:	b8 18 00 00 00       	mov    $0x18,%eax
 6b6:	cd 40                	int    $0x40
 6b8:	c3                   	ret    

000006b9 <getgid>:
SYSCALL(getgid)
 6b9:	b8 19 00 00 00       	mov    $0x19,%eax
 6be:	cd 40                	int    $0x40
 6c0:	c3                   	ret    

000006c1 <getppid>:
SYSCALL(getppid)
 6c1:	b8 1a 00 00 00       	mov    $0x1a,%eax
 6c6:	cd 40                	int    $0x40
 6c8:	c3                   	ret    

000006c9 <setuid>:
SYSCALL(setuid)
 6c9:	b8 1b 00 00 00       	mov    $0x1b,%eax
 6ce:	cd 40                	int    $0x40
 6d0:	c3                   	ret    

000006d1 <setgid>:
SYSCALL(setgid)
 6d1:	b8 1c 00 00 00       	mov    $0x1c,%eax
 6d6:	cd 40                	int    $0x40
 6d8:	c3                   	ret    

000006d9 <getprocs>:
SYSCALL(getprocs)
 6d9:	b8 1d 00 00 00       	mov    $0x1d,%eax
 6de:	cd 40                	int    $0x40
 6e0:	c3                   	ret    

000006e1 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 6e1:	55                   	push   %ebp
 6e2:	89 e5                	mov    %esp,%ebp
 6e4:	83 ec 18             	sub    $0x18,%esp
 6e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ea:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 6ed:	83 ec 04             	sub    $0x4,%esp
 6f0:	6a 01                	push   $0x1
 6f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
 6f5:	50                   	push   %eax
 6f6:	ff 75 08             	pushl  0x8(%ebp)
 6f9:	e8 23 ff ff ff       	call   621 <write>
 6fe:	83 c4 10             	add    $0x10,%esp
}
 701:	90                   	nop
 702:	c9                   	leave  
 703:	c3                   	ret    

00000704 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 704:	55                   	push   %ebp
 705:	89 e5                	mov    %esp,%ebp
 707:	53                   	push   %ebx
 708:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 70b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 712:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 716:	74 17                	je     72f <printint+0x2b>
 718:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 71c:	79 11                	jns    72f <printint+0x2b>
    neg = 1;
 71e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 725:	8b 45 0c             	mov    0xc(%ebp),%eax
 728:	f7 d8                	neg    %eax
 72a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 72d:	eb 06                	jmp    735 <printint+0x31>
  } else {
    x = xx;
 72f:	8b 45 0c             	mov    0xc(%ebp),%eax
 732:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 73c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 73f:	8d 41 01             	lea    0x1(%ecx),%eax
 742:	89 45 f4             	mov    %eax,-0xc(%ebp)
 745:	8b 5d 10             	mov    0x10(%ebp),%ebx
 748:	8b 45 ec             	mov    -0x14(%ebp),%eax
 74b:	ba 00 00 00 00       	mov    $0x0,%edx
 750:	f7 f3                	div    %ebx
 752:	89 d0                	mov    %edx,%eax
 754:	0f b6 80 4c 0f 00 00 	movzbl 0xf4c(%eax),%eax
 75b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 75f:	8b 5d 10             	mov    0x10(%ebp),%ebx
 762:	8b 45 ec             	mov    -0x14(%ebp),%eax
 765:	ba 00 00 00 00       	mov    $0x0,%edx
 76a:	f7 f3                	div    %ebx
 76c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 76f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 773:	75 c7                	jne    73c <printint+0x38>
  if(neg)
 775:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 779:	74 2d                	je     7a8 <printint+0xa4>
    buf[i++] = '-';
 77b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77e:	8d 50 01             	lea    0x1(%eax),%edx
 781:	89 55 f4             	mov    %edx,-0xc(%ebp)
 784:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 789:	eb 1d                	jmp    7a8 <printint+0xa4>
    putc(fd, buf[i]);
 78b:	8d 55 dc             	lea    -0x24(%ebp),%edx
 78e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 791:	01 d0                	add    %edx,%eax
 793:	0f b6 00             	movzbl (%eax),%eax
 796:	0f be c0             	movsbl %al,%eax
 799:	83 ec 08             	sub    $0x8,%esp
 79c:	50                   	push   %eax
 79d:	ff 75 08             	pushl  0x8(%ebp)
 7a0:	e8 3c ff ff ff       	call   6e1 <putc>
 7a5:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 7a8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7b0:	79 d9                	jns    78b <printint+0x87>
    putc(fd, buf[i]);
}
 7b2:	90                   	nop
 7b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 7b6:	c9                   	leave  
 7b7:	c3                   	ret    

000007b8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7b8:	55                   	push   %ebp
 7b9:	89 e5                	mov    %esp,%ebp
 7bb:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7be:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 7c5:	8d 45 0c             	lea    0xc(%ebp),%eax
 7c8:	83 c0 04             	add    $0x4,%eax
 7cb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 7ce:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 7d5:	e9 59 01 00 00       	jmp    933 <printf+0x17b>
    c = fmt[i] & 0xff;
 7da:	8b 55 0c             	mov    0xc(%ebp),%edx
 7dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7e0:	01 d0                	add    %edx,%eax
 7e2:	0f b6 00             	movzbl (%eax),%eax
 7e5:	0f be c0             	movsbl %al,%eax
 7e8:	25 ff 00 00 00       	and    $0xff,%eax
 7ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 7f0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7f4:	75 2c                	jne    822 <printf+0x6a>
      if(c == '%'){
 7f6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7fa:	75 0c                	jne    808 <printf+0x50>
        state = '%';
 7fc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 803:	e9 27 01 00 00       	jmp    92f <printf+0x177>
      } else {
        putc(fd, c);
 808:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 80b:	0f be c0             	movsbl %al,%eax
 80e:	83 ec 08             	sub    $0x8,%esp
 811:	50                   	push   %eax
 812:	ff 75 08             	pushl  0x8(%ebp)
 815:	e8 c7 fe ff ff       	call   6e1 <putc>
 81a:	83 c4 10             	add    $0x10,%esp
 81d:	e9 0d 01 00 00       	jmp    92f <printf+0x177>
      }
    } else if(state == '%'){
 822:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 826:	0f 85 03 01 00 00    	jne    92f <printf+0x177>
      if(c == 'd'){
 82c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 830:	75 1e                	jne    850 <printf+0x98>
        printint(fd, *ap, 10, 1);
 832:	8b 45 e8             	mov    -0x18(%ebp),%eax
 835:	8b 00                	mov    (%eax),%eax
 837:	6a 01                	push   $0x1
 839:	6a 0a                	push   $0xa
 83b:	50                   	push   %eax
 83c:	ff 75 08             	pushl  0x8(%ebp)
 83f:	e8 c0 fe ff ff       	call   704 <printint>
 844:	83 c4 10             	add    $0x10,%esp
        ap++;
 847:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 84b:	e9 d8 00 00 00       	jmp    928 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 850:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 854:	74 06                	je     85c <printf+0xa4>
 856:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 85a:	75 1e                	jne    87a <printf+0xc2>
        printint(fd, *ap, 16, 0);
 85c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 85f:	8b 00                	mov    (%eax),%eax
 861:	6a 00                	push   $0x0
 863:	6a 10                	push   $0x10
 865:	50                   	push   %eax
 866:	ff 75 08             	pushl  0x8(%ebp)
 869:	e8 96 fe ff ff       	call   704 <printint>
 86e:	83 c4 10             	add    $0x10,%esp
        ap++;
 871:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 875:	e9 ae 00 00 00       	jmp    928 <printf+0x170>
      } else if(c == 's'){
 87a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 87e:	75 43                	jne    8c3 <printf+0x10b>
        s = (char*)*ap;
 880:	8b 45 e8             	mov    -0x18(%ebp),%eax
 883:	8b 00                	mov    (%eax),%eax
 885:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 888:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 88c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 890:	75 25                	jne    8b7 <printf+0xff>
          s = "(null)";
 892:	c7 45 f4 dc 0c 00 00 	movl   $0xcdc,-0xc(%ebp)
        while(*s != 0){
 899:	eb 1c                	jmp    8b7 <printf+0xff>
          putc(fd, *s);
 89b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89e:	0f b6 00             	movzbl (%eax),%eax
 8a1:	0f be c0             	movsbl %al,%eax
 8a4:	83 ec 08             	sub    $0x8,%esp
 8a7:	50                   	push   %eax
 8a8:	ff 75 08             	pushl  0x8(%ebp)
 8ab:	e8 31 fe ff ff       	call   6e1 <putc>
 8b0:	83 c4 10             	add    $0x10,%esp
          s++;
 8b3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 8b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8ba:	0f b6 00             	movzbl (%eax),%eax
 8bd:	84 c0                	test   %al,%al
 8bf:	75 da                	jne    89b <printf+0xe3>
 8c1:	eb 65                	jmp    928 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8c3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 8c7:	75 1d                	jne    8e6 <printf+0x12e>
        putc(fd, *ap);
 8c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8cc:	8b 00                	mov    (%eax),%eax
 8ce:	0f be c0             	movsbl %al,%eax
 8d1:	83 ec 08             	sub    $0x8,%esp
 8d4:	50                   	push   %eax
 8d5:	ff 75 08             	pushl  0x8(%ebp)
 8d8:	e8 04 fe ff ff       	call   6e1 <putc>
 8dd:	83 c4 10             	add    $0x10,%esp
        ap++;
 8e0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8e4:	eb 42                	jmp    928 <printf+0x170>
      } else if(c == '%'){
 8e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8ea:	75 17                	jne    903 <printf+0x14b>
        putc(fd, c);
 8ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8ef:	0f be c0             	movsbl %al,%eax
 8f2:	83 ec 08             	sub    $0x8,%esp
 8f5:	50                   	push   %eax
 8f6:	ff 75 08             	pushl  0x8(%ebp)
 8f9:	e8 e3 fd ff ff       	call   6e1 <putc>
 8fe:	83 c4 10             	add    $0x10,%esp
 901:	eb 25                	jmp    928 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 903:	83 ec 08             	sub    $0x8,%esp
 906:	6a 25                	push   $0x25
 908:	ff 75 08             	pushl  0x8(%ebp)
 90b:	e8 d1 fd ff ff       	call   6e1 <putc>
 910:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 913:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 916:	0f be c0             	movsbl %al,%eax
 919:	83 ec 08             	sub    $0x8,%esp
 91c:	50                   	push   %eax
 91d:	ff 75 08             	pushl  0x8(%ebp)
 920:	e8 bc fd ff ff       	call   6e1 <putc>
 925:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 928:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 92f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 933:	8b 55 0c             	mov    0xc(%ebp),%edx
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	01 d0                	add    %edx,%eax
 93b:	0f b6 00             	movzbl (%eax),%eax
 93e:	84 c0                	test   %al,%al
 940:	0f 85 94 fe ff ff    	jne    7da <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 946:	90                   	nop
 947:	c9                   	leave  
 948:	c3                   	ret    

00000949 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 949:	55                   	push   %ebp
 94a:	89 e5                	mov    %esp,%ebp
 94c:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 94f:	8b 45 08             	mov    0x8(%ebp),%eax
 952:	83 e8 08             	sub    $0x8,%eax
 955:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 958:	a1 68 0f 00 00       	mov    0xf68,%eax
 95d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 960:	eb 24                	jmp    986 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 962:	8b 45 fc             	mov    -0x4(%ebp),%eax
 965:	8b 00                	mov    (%eax),%eax
 967:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 96a:	77 12                	ja     97e <free+0x35>
 96c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 96f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 972:	77 24                	ja     998 <free+0x4f>
 974:	8b 45 fc             	mov    -0x4(%ebp),%eax
 977:	8b 00                	mov    (%eax),%eax
 979:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 97c:	77 1a                	ja     998 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 981:	8b 00                	mov    (%eax),%eax
 983:	89 45 fc             	mov    %eax,-0x4(%ebp)
 986:	8b 45 f8             	mov    -0x8(%ebp),%eax
 989:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 98c:	76 d4                	jbe    962 <free+0x19>
 98e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 991:	8b 00                	mov    (%eax),%eax
 993:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 996:	76 ca                	jbe    962 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 998:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99b:	8b 40 04             	mov    0x4(%eax),%eax
 99e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9a8:	01 c2                	add    %eax,%edx
 9aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ad:	8b 00                	mov    (%eax),%eax
 9af:	39 c2                	cmp    %eax,%edx
 9b1:	75 24                	jne    9d7 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 9b3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b6:	8b 50 04             	mov    0x4(%eax),%edx
 9b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bc:	8b 00                	mov    (%eax),%eax
 9be:	8b 40 04             	mov    0x4(%eax),%eax
 9c1:	01 c2                	add    %eax,%edx
 9c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9c6:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 9c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cc:	8b 00                	mov    (%eax),%eax
 9ce:	8b 10                	mov    (%eax),%edx
 9d0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9d3:	89 10                	mov    %edx,(%eax)
 9d5:	eb 0a                	jmp    9e1 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 9d7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9da:	8b 10                	mov    (%eax),%edx
 9dc:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9df:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 9e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9e4:	8b 40 04             	mov    0x4(%eax),%eax
 9e7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f1:	01 d0                	add    %edx,%eax
 9f3:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9f6:	75 20                	jne    a18 <free+0xcf>
    p->s.size += bp->s.size;
 9f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9fb:	8b 50 04             	mov    0x4(%eax),%edx
 9fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a01:	8b 40 04             	mov    0x4(%eax),%eax
 a04:	01 c2                	add    %eax,%edx
 a06:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a09:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a0c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0f:	8b 10                	mov    (%eax),%edx
 a11:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a14:	89 10                	mov    %edx,(%eax)
 a16:	eb 08                	jmp    a20 <free+0xd7>
  } else
    p->s.ptr = bp;
 a18:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a1e:	89 10                	mov    %edx,(%eax)
  freep = p;
 a20:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a23:	a3 68 0f 00 00       	mov    %eax,0xf68
}
 a28:	90                   	nop
 a29:	c9                   	leave  
 a2a:	c3                   	ret    

00000a2b <morecore>:

static Header*
morecore(uint nu)
{
 a2b:	55                   	push   %ebp
 a2c:	89 e5                	mov    %esp,%ebp
 a2e:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a31:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a38:	77 07                	ja     a41 <morecore+0x16>
    nu = 4096;
 a3a:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a41:	8b 45 08             	mov    0x8(%ebp),%eax
 a44:	c1 e0 03             	shl    $0x3,%eax
 a47:	83 ec 0c             	sub    $0xc,%esp
 a4a:	50                   	push   %eax
 a4b:	e8 39 fc ff ff       	call   689 <sbrk>
 a50:	83 c4 10             	add    $0x10,%esp
 a53:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a56:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a5a:	75 07                	jne    a63 <morecore+0x38>
    return 0;
 a5c:	b8 00 00 00 00       	mov    $0x0,%eax
 a61:	eb 26                	jmp    a89 <morecore+0x5e>
  hp = (Header*)p;
 a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a66:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a6c:	8b 55 08             	mov    0x8(%ebp),%edx
 a6f:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a72:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a75:	83 c0 08             	add    $0x8,%eax
 a78:	83 ec 0c             	sub    $0xc,%esp
 a7b:	50                   	push   %eax
 a7c:	e8 c8 fe ff ff       	call   949 <free>
 a81:	83 c4 10             	add    $0x10,%esp
  return freep;
 a84:	a1 68 0f 00 00       	mov    0xf68,%eax
}
 a89:	c9                   	leave  
 a8a:	c3                   	ret    

00000a8b <malloc>:

void*
malloc(uint nbytes)
{
 a8b:	55                   	push   %ebp
 a8c:	89 e5                	mov    %esp,%ebp
 a8e:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a91:	8b 45 08             	mov    0x8(%ebp),%eax
 a94:	83 c0 07             	add    $0x7,%eax
 a97:	c1 e8 03             	shr    $0x3,%eax
 a9a:	83 c0 01             	add    $0x1,%eax
 a9d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 aa0:	a1 68 0f 00 00       	mov    0xf68,%eax
 aa5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 aa8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aac:	75 23                	jne    ad1 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 aae:	c7 45 f0 60 0f 00 00 	movl   $0xf60,-0x10(%ebp)
 ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab8:	a3 68 0f 00 00       	mov    %eax,0xf68
 abd:	a1 68 0f 00 00       	mov    0xf68,%eax
 ac2:	a3 60 0f 00 00       	mov    %eax,0xf60
    base.s.size = 0;
 ac7:	c7 05 64 0f 00 00 00 	movl   $0x0,0xf64
 ace:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad4:	8b 00                	mov    (%eax),%eax
 ad6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adc:	8b 40 04             	mov    0x4(%eax),%eax
 adf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 ae2:	72 4d                	jb     b31 <malloc+0xa6>
      if(p->s.size == nunits)
 ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae7:	8b 40 04             	mov    0x4(%eax),%eax
 aea:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 aed:	75 0c                	jne    afb <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 af2:	8b 10                	mov    (%eax),%edx
 af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 af7:	89 10                	mov    %edx,(%eax)
 af9:	eb 26                	jmp    b21 <malloc+0x96>
      else {
        p->s.size -= nunits;
 afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afe:	8b 40 04             	mov    0x4(%eax),%eax
 b01:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b04:	89 c2                	mov    %eax,%edx
 b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b09:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0f:	8b 40 04             	mov    0x4(%eax),%eax
 b12:	c1 e0 03             	shl    $0x3,%eax
 b15:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b1b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b1e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b24:	a3 68 0f 00 00       	mov    %eax,0xf68
      return (void*)(p + 1);
 b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b2c:	83 c0 08             	add    $0x8,%eax
 b2f:	eb 3b                	jmp    b6c <malloc+0xe1>
    }
    if(p == freep)
 b31:	a1 68 0f 00 00       	mov    0xf68,%eax
 b36:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b39:	75 1e                	jne    b59 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 b3b:	83 ec 0c             	sub    $0xc,%esp
 b3e:	ff 75 ec             	pushl  -0x14(%ebp)
 b41:	e8 e5 fe ff ff       	call   a2b <morecore>
 b46:	83 c4 10             	add    $0x10,%esp
 b49:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b4c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b50:	75 07                	jne    b59 <malloc+0xce>
        return 0;
 b52:	b8 00 00 00 00       	mov    $0x0,%eax
 b57:	eb 13                	jmp    b6c <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b62:	8b 00                	mov    (%eax),%eax
 b64:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b67:	e9 6d ff ff ff       	jmp    ad9 <malloc+0x4e>
}
 b6c:	c9                   	leave  
 b6d:	c3                   	ret    
