
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