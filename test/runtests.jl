using Expresso
using FactCheck

@! ["..."],
module TestModule

export f

f(x) = g(2x)

g(x) = -x

export T, getx, setx!

@! ["..."],
type T
    x :: Int := begin
        "..."
        getx()     = self.x
        "..."
        setx!(val) = self.x += val
    end
end

end

facts("'@!'") do
    context("Modules") do
        @fact TestModule.f(1) => -2
        @fact :f ∈ names(TestModule) => true
        @fact :T ∈ names(TestModule) => true
        @fact :g ∈ names(TestModule) => false
        @fact :f ∈ names(TestModule, true) => true
        @fact :T ∈ names(TestModule, true) => true
        @fact :g ∈ names(TestModule, true) => false
    end
    context("Types") do
        t = TestModule.T(1)
        @fact TestModule.getx(t) => 1
        @fact TestModule.setx!(t, 1) => 2
        @fact TestModule.getx(t) => 2
        @fact :x ∈ fieldnames(TestModule.T) => false
    end
end

facts("'@\\'") do
    @fact (@\ 1' - 1' / 2')(1, 2) => ((x, y) -> x - x / y)(1, 2)
    @fact (@\ 2*(1') - 1' / 2' + 3')(1, 2, 3) => ((x, y, z) -> 2x - x / y + z)(1, 2, 3)
end

@defmacro:end() :()

facts("'@defmacro'") do
    @fact @end() => ()
    @for i in 1:3 @fact i => i
end

module A
type T end
type S end
f(::T) = A
f(::T, x) = A
f(::T, ::S) = A
g(x, y) = A
h(::T; a = 1) = a
end

module B
type T end
type S end
f(::T) = B
f(::T, x) = B
f(::T, ::S) = B
g(x, y) = B
h(::T; a = 2) = a
end

module C
type T end
type S end
f(::T) = C
f(::T, x) = C
f(::T, ::S) = C
g(x, y) = C
h(::T; a = 3) = a
end

@merge f A B C
@merge g C B A

@kwmerge h A B C

facts("'@merge'") do
    @fact f(A.T()) => A
    @fact f(B.T()) => B
    @fact f(C.T()) => C
    @fact f(A.T(), 1) => A
    @fact f(B.T(), 1) => B
    @fact f(C.T(), 1) => C
    @fact f(A.T(), A.S()) => A
    @fact f(B.T(), B.S()) => B
    @fact f(C.T(), C.S()) => C
    @fact g(A.T(), B.S()) => C

    @fact h(A.T()) => 1
    @fact h(B.T()) => 2
    @fact h(C.T()) => 3
    @fact h(A.T(), a = 5) => 5
    @fact h(B.T(), a = 6) => 6
    @fact h(C.T(), a = 7) => 7
end

facts("Dispatch") do
    @fact Head(:(module M end)) => Head{:module}()
    @fact H"call, macrocall" => Union{Head{:call}, Head{:macrocall}}
end

facts("Anonymous Types") do
    a = @type(
        x = 1,
        y = "foo",
        z = [1, 2, 3],
    )
    @fact a.x => 1
    @fact a.y => "foo"
    @fact a.z => [1, 2, 3]
    @fact isimmutable(a) => false

    b = @immutable(
        x = 1.0,
        y = 'b',
        z = (1, 2, 3),
    )
    @fact b.x => 1.0
    @fact b.y => 'b'
    @fact b.z => (1, 2, 3)
    @fact isimmutable(b) => true
end
