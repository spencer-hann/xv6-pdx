#ifdef CS333_P2
#include "types.h"
#include "user.h"

int
main(int argc, char* argv[])
{
  uint uid, gid, ppid;
  int flag, errors = 0;

//UID tests:
  uid = getuid();
  printf(2, "Current UID is: %d\n", uid);
  printf(2, "Setting UID to 100\n");
  flag = setuid(100);
  uid = getuid();
  printf(2, "Current UID is: %d\n\n", uid);
  if (flag == -1 || uid != 100) {
    printf(2, "setuid failed\n\n");
    ++errors;
  }

  printf(2, "Setting UID to invalid 100000\n");
  flag = setuid(100000);
  uid = getuid();
  printf(2, "Current UID is: %d\n\n", uid);
  if (flag == -1)
    printf(2, "setuid failed (good)\n\n");
  else
    ++errors;

  printf(2, "Setting UID to invalid -1\n");
  flag = setuid(-1);
  uid = getuid();
  printf(2, "Current UID is: %d\n\n", uid);
  if (flag == -1)
    printf(2, "setuid failed (good)\n\n");
  else
    ++errors;

// GID tests:
  gid = getgid();
  printf(2, "Current GID is: %d\n", gid);
  printf(2, "Setting GID to 100\n");
  flag = setgid(100);
  gid = getgid();
  printf(2, "Current GID is: %d\n\n", gid);
  if (flag == -1 || gid != 100) {
    printf(2, "setgid failed\n\n");
     ++errors;
  }

  printf(2, "Setting GID to invalid 100000\n");
  flag = setgid(100000);
  gid = getgid();
  printf(2, "Current GID is: %d\n\n", gid);
  if (flag == -1)
    printf(2, "setgid failed (good)\n\n");
  else
    ++errors;

  printf(2, "Setting GID to invalid -1\n");
  flag = setgid(-1);
  gid = getgid();
  printf(2, "Current GID is: %d\n\n", gid);
  if (flag == -1)
    printf(2, "setgid failed (good)\n\n");
  else
    ++errors;

//PPID
  ppid = getppid();
  printf(2, "My PPID is: %d\n", ppid);
  printf(2, "End of test.\n");

//Summary
  printf(2, "%d Errors.\n\n", errors);
  exit();
}
#endif
