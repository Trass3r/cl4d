
module common;

//! calculate actual size of an array
//! i.e. array.length * ElementType.sizeof
size_t arrsizeof(T)(T[] array)
{
	static if(__traits(isStaticArray, array))
		return array.sizeof;
	else
		return array.length * T.sizeof;
}

unittest
{
	int[] a = new int[5];
	assert(a.arrsizeof == 20);
	int[4] b;
	assert(b.arrsizeof == 16);
}
