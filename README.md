# NAME

Class::Simple - Simple Object-Oriented Base Class

# SYNOPSIS

    package Foo:
    use base qw(Class::Simple);

    BEGIN
    {
          Foo->privatize(qw(attrib1 attrib2)); # ...or not.
    }
    my $obj = Foo->new();

    $obj->attrib(1);     # The same as...
    $obj->set_attrib(1); # ...this.

    my $var = $obj->get_attrib(); # The same as...
    $var = $obj->attrib;          # ...this.

    $obj->raise_attrib(); # The same as...
    $obj->set_attrib(1);  # ...this.

    $obj->clear_attrib();    # The same as...
    $obj->set_attrib(undef); # ...this
    $obj->attrib(undef);     # ...and this.

    $obj->readonly_attrib(4);

    sub foo
    {
    my $self = shift;
    my $value = shift;

      $self->_foo($value);
      do_other_things(@_);
      ...
    }

    my $str = Storable::freeze($obj);
    # Save $str to a file
    ...
    # Read contents of file into $new_str
    $new_obj = Storable::thaw($new_str);

    sub BUILD
    {
    my $self = shift;

      # Various initializations
    }

# DESCRIPTION

This is a simple object-oriented base class.  There are plenty of others
that are much more thorough and whatnot but sometimes I want something
simple so I can get just going (no doubt because I am a simple guy)
so I use this.

What do I mean by simple?  First off, I don't want to have to list out
all my methods beforehand.  I just want to use them (Yeah, yeah, it doesn't
catch typos...well, by default--see **ATTRIBUTES()** below).
Next, I want to be able to
call my methods by $obj->foo(1) or $obj->set\_foo(1), by $obj->foo() or
$obj->get\_foo().  Don't tell ME I have to use get\_ and set\_ (I would just
override that restriction in Class::Std anyway).  Simple!

I did want some neat features, though, so these are inside-out objects
(meaning the object isn't simply a hash so you can't just go in and
muck with attributtes outside of methods),
privatization of methods is supported, as is serialization out and back
in again.

It's important to note, though, that one does not have to use the extra
features to use **Class::Simple**.  All you need to get going is:

        package MyPackage;
        use base qw(Class::Simple);

And that's it.  To use it?:

        use MyPackage;

        my $obj = MyPackage->new();
        $obj->set_attr($value);

Heck, you don't even need that much:

        use Class::Simple;

        my $obj = Class::Simple->new();
        $obj->set_attr($value);

Why would you want to use a (not quite) anonymous object?
Well, you can use it to simulate the interface of a class
to do some testing and debugging.

## Garbage Collection

Garbage collection is handled automatically by **Class::Simple**.
The only thing the user has to worry about is cleaning up dangling
and circular references.

Example:

        my $a = Foo->new();
        {
                my $b = Foo->new();
                $b->set_yell('Ouch!');
                $a->next = $b;
        }
        print $a->next->yell;

Even though **$b** goes out of scope when the block exits,
**$a-**next()> still refers to it so **DESTROY** is never called on **$b**
and "Ouch!" is printed.
Why is **$a** referring to an out-of-scope object in the first place?
Programmer error--there is only so much that **Class::Simple** can fix :-).

# METHODS

## Class Methods

- **new(**\[attr => val...\]**)**

    Returns the object and calls **BUILD()**.

    If key/value pairs are included, the keys will be treated as attributes
    and the values will be used to initialize its respective attribute.

- **privatize(**qw(method1 method2 ...**)**

    Mark the given methods as being private to the class.
    They will only be accessible to the class or its children.
    Make sure this is called before you start instantiating objects.
    It should probably be put in a **BEGIN** or **INIT** block.

## Optional User-defined Methods

- **BUILD()**

    If there is initialization that you would like to do after an
    object is created, this is the place to do it.

- **NONEW()**

    If this is defined in a class, **new()** will not work for that class.
    You can use this in an abstract class when only concrete classes
    descended from the abstract class should have **new()**.

- **DEMOLISH()**

    If you want to write your own DESTROY, don't.
    Do it here in DEMOLISH, which will be called by DESTROY.

- **ATTRIBUTES()**

    Did I say we can't catch typos?
    Well, that's only partially true.
    If this is defined in your class, it needs to return an array of
    attribute names.
    If it is defined, only the attributes returned will be allowed
    to be used.
    Trying to get or set an attribute not in the list will be a fatal error.
    Note that this is an **optional** method.
    You **do not** have to define your attributes ahead of time to use
    Class::Simple.
    This provides an optional layer of error-checking.

## Object Methods

- **init()**

    I lied above when I wrote that **new()** called **BUILD()**.
    It really calls **init()** and **init()** calls **BUILD()**.
    Actually, it calls all the **BUILD()**s of all the ancestor classes
    (in a recursive, left-to-right fashion).
    If, for some reason, you do not want to do that,
    simply write your own **init()** and this will be short-circuited.

- **CLASS**

    The class this object was blessed in.
    Really used for internal housekeeping but I might as well let you
    know about it in case it would be helpful.
    It is readonly (see below).

- **STORABLE\_freeze**

    See **Serialization** below.

- **STORABLE\_thaw**

    See **Serialization** below.

If you want an attribute named "foo", just start using the following
(no pre-declaration is needed):

- **foo(**\[val\]**)**

    Without any parameters, it returns the value of foo.
    With a parameter, it sets foo to the value of the parameter and returns it.
    Even if that value is undef.

- **get\_foo()**

    Returns the value of foo.

- **set\_foo(**val**)**

    Sets foo to the value of the given parameter and returns it.

- **raise\_foo()**

    The idea is that if foo is a flag, this raises the flag by
    setting foo to 1 and returns it.

- **clear\_foo()**

    Set foo to undef and returns it.

- **readonly\_foo(**val**)**

    Set foo to the given value, then disallow any further changing of foo.
    Returns the value.

- **\_foo(**\[val\]**)**

    If you have an attribute foo but you want to override the default method,
    you can use **\_foo** to keep the data.
    That way you don't have to roll your own way of storing the data,
    possibly breaking inside-out.
    Underscore methods are automatically privatized.
    Also works as **set\_\_foo** and **get\_\_foo**.

## Serialization

There are hooks here to work with [Storable](https://metacpan.org/pod/Storable) to serialize objects.
To serialize a Class::Simple-derived object:

    use Storable;

    my $serialized = Storable::freeze($obj);

To reconstitute an object saved with **freeze()**:

    my $new_obj = Storable::thaw($serialized_str);

# CAVEATS

If an ancestor class has a **foo** attribute, children cannot have their
own **foo**.  They get their parent's **foo**.

I don't actually have a need for DUMP and SLURP but I thought they
would be nice to include.
If you know how I can make them useful for someone who would actually
use them, let me know.

# SEE ALSO

[Class::Std](https://metacpan.org/pod/Class%3A%3AStd) is an excellent introduction to the concept
of inside-out objects in Perl
(they are referred to as the "flyweight pattern" in Damian Conway's
_Object Oriented Perl_).
Many things here, like the name **DEMOLISH()**, were shamelessly stolen from it.
Standing on the shoulders of giants and all that.

[Storable](https://metacpan.org/pod/Storable)

# AUTHOR

Michael Sullivan, <perldude@mac.com>

# REPOSITORY

[https://github.com/perldude/Class-Simple](https://github.com/perldude/Class-Simple)

# COPYRIGHT AND LICENSE

Copyright (C) 2007-2020 by Michael Sullivan

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.
