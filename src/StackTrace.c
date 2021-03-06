/*******************************************************************************
 * Copyright (c) 2009, 2012 IBM Corp.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *    http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 *
 * Contributors:
 *    Ian Craggs - initial API and implementation and/or initial documentation
 *******************************************************************************/

#include "StackTrace.h"
#include "Log.h"
#include "LinkedList.h"

#include "Clients.h"
#include "Thread.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#if defined(WIN32)
#define snprintf _snprintf
#endif

/*BE
def STACKENTRY
{
	n32 ptr STRING open "name"
	n32 dec "line"
}

defList(STACKENTRY)
BE*/

#define MAX_STACK_DEPTH 50
#define MAX_FUNCTION_NAME_LENGTH 30
#define MAX_THREADS 255

typedef struct
{
	unsigned long threadid;
	char name[MAX_FUNCTION_NAME_LENGTH];
	int line;
} stackEntry;

typedef struct
{
#ifdef __VMS
	unsigned long long id;
#else
	unsigned long id;
#endif
	int maxdepth;
	int current_depth;
	stackEntry callstack[MAX_STACK_DEPTH];
} threadEntry;

#include "StackTrace.h"

static int thread_count = 0;
static threadEntry threads[MAX_THREADS];
static threadEntry *cur_thread = NULL;

#if defined(WIN32)
mutex_type stack_mutex;
#else
static pthread_mutex_t stack_mutex_store = PTHREAD_MUTEX_INITIALIZER;
static mutex_type stack_mutex = &stack_mutex_store;
#endif


int setStack(int create)
{
	int i = -1;
	thread_id_type curid = Thread_getid();

	cur_thread = NULL;
	for (i = 0; i < MAX_THREADS && i < thread_count; ++i)
	{
#ifdef __VMS
		if (threads[i].id == (unsigned long long) curid)
#else
		if (threads[i].id == curid)
#endif
		{
			cur_thread = &threads[i];
			break;
		}
	}

	if (cur_thread == NULL && create && thread_count < MAX_THREADS)
	{
		cur_thread = &threads[thread_count];
#ifdef __VMS
		cur_thread->id = (unsigned long long) curid;
#else
		cur_thread->id = curid;
#endif
		cur_thread->maxdepth = 0;
		cur_thread->current_depth = 0;
		++thread_count;
	}
	return cur_thread != NULL; /* good == 1 */
}

void StackTrace_entry(const char* name, int line, int trace_level)
{
	Thread_lock_mutex(stack_mutex);
	if (!setStack(1))
		goto exit;
	if (trace_level != -1)
		Log_stackTrace(trace_level, 9, cur_thread->id, cur_thread->current_depth, name, line, NULL);
	strncpy(cur_thread->callstack[cur_thread->current_depth].name, name, sizeof(cur_thread->callstack[0].name)-1);
	cur_thread->callstack[(cur_thread->current_depth)++].line = line;
	if (cur_thread->current_depth > cur_thread->maxdepth)
		cur_thread->maxdepth = cur_thread->current_depth;
	if (cur_thread->current_depth >= MAX_STACK_DEPTH)
		Log(LOG_FATAL, -1, "Max stack depth exceeded");
exit:
	Thread_unlock_mutex(stack_mutex);
}


void StackTrace_exit(const char* name, int line, void* rc, int trace_level)
{
	Thread_lock_mutex(stack_mutex);
	if (!setStack(0))
		goto exit;
	if (--(cur_thread->current_depth) < 0)
		Log(LOG_FATAL, -1, "Minimum stack depth exceeded for thread %lu", cur_thread->id);
	if (strncmp(cur_thread->callstack[cur_thread->current_depth].name, name, sizeof(cur_thread->callstack[0].name)-1) != 0)
		Log(LOG_FATAL, -1, "Stack mismatch. Entry:%s Exit:%s\n", cur_thread->callstack[cur_thread->current_depth].name, name);
	if (trace_level != -1)
	{
		if (rc == NULL)
			Log_stackTrace(trace_level, 10, cur_thread->id, cur_thread->current_depth, name, line, NULL);
		else
			Log_stackTrace(trace_level, 11, cur_thread->id, cur_thread->current_depth, name, line, (int*)rc);
	}
exit:
	Thread_unlock_mutex(stack_mutex);
}


void StackTrace_printStack(char* dest)
{
	FILE* file = stdout;
	int t = 0;

	for (t = 0; t < thread_count; ++t)
	{
		threadEntry *cur_thread = &threads[t];

		if (cur_thread->id > 0)
		{
			int i = cur_thread->current_depth - 1;
#ifdef __VMS
			fprintf(file, "=========== Start of stack trace for thread %llu ==========\n", cur_thread->id);
#else
			fprintf(file, "=========== Start of stack trace for thread %lu ==========\n", cur_thread->id);
#endif
			if (i >= 0)
			{
				fprintf(file, "%s (%d)\n", cur_thread->callstack[i].name, cur_thread->callstack[i].line);
				while (--i >= 0)
					fprintf(file, "   at %s (%d)\n", cur_thread->callstack[i].name, cur_thread->callstack[i].line);
			}
#ifdef __VMS
			fprintf(file, "=========== End of stack trace for thread %llu ==========\n\n", cur_thread->id);
#else
			fprintf(file, "=========== End of stack trace for thread %lu ==========\n\n", cur_thread->id);
#endif
		}
	}
	if (file != stdout && file != stderr && file != NULL)
		fclose(file);
}


char* StackTrace_get(unsigned long threadid)
{
	int bufsize = 256;
	char* buf = NULL;
	int t = 0;

	if ((buf = malloc(bufsize)) == NULL)
		goto exit;
	buf[0] = '\0';
	for (t = 0; t < thread_count; ++t)
	{
		threadEntry *cur_thread = &threads[t];

		if (cur_thread->id == threadid)
		{
			int i = cur_thread->current_depth - 1;
			int curpos = 0;

			if (i >= 0)
			{
				curpos += snprintf(&buf[curpos], bufsize - curpos -1,
						"%s (%d)\n", cur_thread->callstack[i].name, cur_thread->callstack[i].line);
				while (--i >= 0)
					curpos += snprintf(&buf[curpos], bufsize - curpos -1,
							"   at %s (%d)\n", cur_thread->callstack[i].name, cur_thread->callstack[i].line);
				if (buf[--curpos] == '\n')
					buf[curpos] = '\0';
			}
			break;
		}
	}
exit:
	return buf;
}

