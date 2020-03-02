#include <string.h>

#include "uim.h"
#include "uim-scm.h"
#include "uim-scm-abbrev.h"
#include "dynlib.h"

static uim_lisp
func0()
{
	return uim_scm_f();
}

static uim_lisp
func1(uim_lisp a1)
{
	return uim_scm_t();
}

static uim_lisp
func2(uim_lisp a1, uim_lisp a2)
{
	return uim_scm_t();
}

static uim_lisp
func3(uim_lisp a1, uim_lisp a2, uim_lisp a3)
{
	return uim_scm_t();
}

static uim_lisp
func4(uim_lisp a1, uim_lisp a2, uim_lisp a3, uim_lisp a4)
{
	return uim_scm_t();
}

static uim_lisp
func5(uim_lisp a1, uim_lisp a2, uim_lisp a3, uim_lisp a4, uim_lisp a5)
{
	return uim_scm_t();
}

void
uim_plugin_instance_init(void)
{
	uim_scm_init_proc0("test0001-lib-func0", func0);
	uim_scm_init_proc1("test0001-lib-func1", func1);
	uim_scm_init_proc2("test0001-lib-func2", func2);
	uim_scm_init_proc3("test0001-lib-func3", func3);
	uim_scm_init_proc4("test0001-lib-func4", func4);
	uim_scm_init_proc5("test0001-lib-func5", func5);
}

void
uim_plugin_instance_quit(void)
{
}
