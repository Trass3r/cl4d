/*
cl4d - object-oriented wrapper for the OpenCL C API
written in the D programming language

Copyright (C) 2009-2010 Andreas Hollandt

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
module common;

package
{
// define string types for compatibility with both D1 and D2
version (D_Version2)
{
	pragma(msg, "D2 detected. Taking care of constness.");

	// we need a mixin cause the code is syntactically illegal under D1
	mixin(`
	alias const(char) cchar; /// const char type
	alias immutable(char) ichar; /// immutable char type

	alias char[] mstring; /// mutable string type
	alias const(char)[] cstring; /// const string type
	alias immutable(char)[] istring; /// immutable string type

	alias wchar[] mwstring;
	alias const(wchar)[] cwstring;
	alias immutable(wchar)[] iwstring;

	alias dchar[] mdstring;
	alias const(dchar)[] cdstring;
	alias immutable(dchar)[] idstring;`);
}
else
{
	pragma(msg, "D1 detected. All strings are mutable.");

	alias char cchar;
	alias char ichar;

	alias char[] mstring;
	alias char[] cstring;
	alias char[] istring;

	alias wchar[] mwstring;
	alias wchar[] cwstring;
	alias wchar[] iwstring;

	alias dchar[] mdstring;
	alias dchar[] cdstring;
	alias dchar[] idstring;
}
}