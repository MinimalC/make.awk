
### make.awk

Welcome to make.awk. This is all about doing C with AWK.

This project is currently a DEBUG version. You need GAWK and Linux, I didn't try this on Windows.

## Install make.awk

```
$ sudo ./run.awk install  # or sudo gawk -f run.awk install

/usr/bin/run.awk is now linked to ~/FIKTIV/make.awk/run.awk.
/usr/bin/make.awk is now linked to ~/FIKTIV/make.awk/make.awk.
```

## Using run.awk

Actually you need `run.awk` to do `make.awk`.

```
$ run.awk

Use run.awk Project.awk [command] [Directory] [File.name]
with a Project.awk BEGIN { __BEGIN("command") } and function Project_command(config) { }
```

## Using make.awk

```
run.awk make.awk +debug executable Project.c 1>&2 2>.Project...report
```

This command creates a folder `.make`, an executable file `Project`, and a file `.Project...report`, which is reporting issues and define's.
