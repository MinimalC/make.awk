

#define __STRING(x) #x

#define __ASMNAME2 (prefix , cname) __STRING ( prefix ) cname

#define __ASMNAME (cname) __ASMNAME2 ( __USER_LABEL_PREFIX__ , cname )

#define __REDIRECT (name , proto , alias)  name proto __asm__ ( __ASMNAME ( # alias ) )

int __REDIRECT(setpgrp, (__pid_t pid, __pid_t pgrp),
    setpgid);


#if defined(__GNUC__)
AWA
#else
OHO
#endif
