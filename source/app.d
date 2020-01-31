import std.stdio;
import std.format;
import ast;
import helper;

string mine()
{
	auto sym = symbols!real(["a", "b", "c"]);
	auto a = sym[0];
	auto b = sym[1];
	auto c = sym[2];
	auto n = c += a + b + 1;
	auto n2 = new Block([n, new Statement(new FunctionCall("writeln", [sym[2]]))]);
	auto ret = format!"%s"(n2);
	return ret;
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
