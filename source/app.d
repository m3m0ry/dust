import std.stdio;
import std.format;
import ast;
import std.conv;
import helper;

string mine()
{
	auto sym = symbols!real(["a", "b", "c"]);
	auto a = sym[0];
	auto b = sym[1];
	auto c = sym[2];
	auto n = c += a + b + 1;
	auto n2 = new Block([n, new Statement(new FunctionCall("writeln", [sym[2]]))]);
	string ret = format!"%s"(n2);
  return ret;
	
	//auto fs = fields!real(["A", "B"], 2, [128,128]);
	//auto A = fs[0];
	//auto B = fs[1];
	//auto jacobi = B[0] = 1./4. *(A[1,0] + A[0,1] + A[-1,0] + A[0,-1]);

	//return jacobi.to!string;
}

void main()
{
	real a = 1;
	real b = 2;
	real c = 3;
	enum string s = mine;
	writeln(s);
	mixin(s);
}
