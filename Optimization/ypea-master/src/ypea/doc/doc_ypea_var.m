%% How to define Decision Variables
% This document shows how to define decision variables with optimization
% problems and use |ypea_var| function,
% which is a part of Yarpiz Evolutionary Algorithms Toolbox (YPEA).

%% Properties of a Decision Variables
% Decision variables are defined and stored as structures in YPEA. Fields
% of a structure which defines a decision variable, are listed below:
%
% * |name|, the name of variables, in final (parsed) solution structure
% * |type|, type of decision variables, which can be one of possible types,
% dicussed later in this document (<#3 Types of Decision Variables>)
% * |size|, the size of matrix representing the decision variable
% * |count|, number of elements in matrix representing the variable
% * |props|, a structure, containing properties of the variable
% * |decode|, a function handle, which decodes a coded vectors into a
% meaningful value of decision variable

%% How to Create a Decision Variables
% To create (define) a decision variables, the function |ypea_var| should
% be used. The general form is as follows:
% 
% |var = ypea_var('name', 'type', 'size', [m n ... p], 'prop1', value1,
% 'prop2', value2, ...);|
% 
% Types of variables and their properties are discussed in the next
% section.

%% Types of Decision Variables
% There are several types of decision variables, available in YPEA. These
% types are listed below. All of variables defined in YPEA, are coded in a
% way, that their corresponding coded values are real numbers in [0,1].
% However, the YPEA is responsible for encoding and decoding the solutions
% and you just need to define the variables and let YPEA do the rest for
% you.

%%
% *Real Variable* (|real|)
%
% This represents real (continuous) decision variables. The lower and upper
% bounds of the variable set, are specified by
% |lower_bound| (or |lb|, for short) and
% |upper_bound| (or |ub|, for short) properties.
%
% _Some Examples_
%

%%
% This defines a scalar real variable, named |x|, which is in the range
% [0, 1]:
var = ypea_var('x', 'real');

%%
% This defines a set of 10 real variables, all of which are in the range
% [-5, +5].
var = ypea_var('y', 'real', 'size', 10, 'lower_bound', -5, 'upper_bound', 5);

%%
% This defines a set of 3 real variables,
% which lie in ranges [-1, 1], [3, 5] and [-10, 2], respectively.
var = ypea_var('z', 'real', 'lb', [-1 3 -10], 'ub', [1 5 2]);

%%
% For example, to have samples of this variable, you may call:
sol = ypea_generate_sample(var)

%%
% Another sample will be:
sol = ypea_generate_sample(var)

%%
% It is possible to define decision variables as matrices. For example this
% line of code, defines a 3-by-5 matrix of real variables, elements of
% which are all in the range of [-3, 8]:
var = ypea_var('X', 'real', 'size', [3 5], 'lb', -3, 'ub', 8);

%%
% And this is a sample of this variable:
sol = ypea_generate_sample(var);
sol.X

%%
% General it is possible to define lower and upper bounds as matrices. An
% example of matrix bounds is presented below:

lb = [-5  1  3
       0  0 -8];
   
ub = [-2  4  7
       1  5  8];

var = ypea_var('A', 'real', 'lower_bound', lb, 'upper_bound', ub);

%%
% Let's generate a sample from this variables:
sol = ypea_generate_sample(var);
sol.A

%%
% *Integer Variable* (|integer|)
%
% This represents integer (discrete) decision variables. 
% Similat to the real variables, the lower and upper bounds of the variable
% are specified by
% |lower_bound| (or |lb|, for short) and
% |upper_bound| (or |ub|, for short) properties.
%
% _Some Examples_
%

%%
% This defines a scalar integer variable, named |n|, which is either 0 or
% 1, i.e. a binary variable:
var = ypea_var('n', 'integer');

%%
% This defines a set of 8 integer variables, all of which are in the range
% [-3, 6].
var = ypea_var('m', 'int', 'size', 8, 'lower_bound', -3, 'upper_bound', 6);

%%
% A Sample of this variable can be generated as follows:
sol = ypea_generate_sample(var)

%%
% This defines a set of 4 integer variables,
% which lie in ranges [-1, 1], [3, 5] and [-10, 2], respectively.
var = ypea_var('p', 'int', 'lb', [-1 3 -10], 'ub', [1 5 2]);

%%
% To have samples of this variable, you may call:
sol = ypea_generate_sample(var)

%%
% Also you may create a complex structure of different decision varibales
% by creating a matrix of variables. For example:
vars = [
    ypea_var('a', 'int', 'size', 3, 'lb', 1, 'ub', 6)
    ypea_var('x', 'real', 'size', 3, 'lb', -2, 'ub', 2)
    ypea_var('m', 'int', 'lb', 0, 'ub', 10)
];

%%
% Let's generate a sample of this:
sol = ypea_generate_sample(vars)

%%
% *Binary Variable* (|binary|)
%
% Binary variable is a special case of integer variable, with lower and
% upper bound set to be 0 and 1, respectively.
%
% _Some Examples_
%

%%
% For example this is a 3-by-6 matrix of binary variables:
var = ypea_var('x', 'bin', 'size', [3 6]);

%%
% Let's generate a sample from this:
sol = ypea_generate_sample(var);
sol.x

%%
% *Permutation Variable* (|permutation|)
%
% Permutation variable represent a permutation of numbers, from 1 to n,
% where n is the length of the permutation. It is possible to have several
% permutations as rows of a matrix.
%
% _Some Examples_
%

%%
% This is a simple permutation variable:
var = ypea_var('tour', 'permutation', 'size', 8);

sol = ypea_generate_sample(var)

%%
% To have mutiple permutations of the same length, it is possible to define
% permutation variable as follows:
var = ypea_var('p', 'perm', 'size', [3 8]);

%%
% which defines 3 permutations of length 8. Let's create a sample of this:
sol = ypea_generate_sample(var);
sol.p

%%
% *Selection Variables* (|selection| and |binary_selection|)
%
% These types of variable are used to select some fixed number of items from
% a predefined list.
% The number of selected items is specified by |selection_count|.
% The binary version, represents the solution as binary flags.
%
% _Some Examples_
%

%%
% This is a simple selection variable:
var = ypea_var('a', 'selection', 'size', 10, 'selection_count', 4);

%%
% which means selection of 4 items among 10. A sample solution may be:
sol = ypea_generate_sample(var)

%%
% The same variable can be defined in binary form:
var = ypea_var('b', 'binary_selection', 'size', 10, 'selection_count', 4);

%%
% and a sample solution may be like this:
sol = ypea_generate_sample(var)

%%
% Just like permutation variables, it is possible to perform multiple
% selections. For example, 3 selection operations, each of which is
% selection of 4 item among 10, can be defined as:
var = ypea_var('c', 'selection', 'size', [3 10], 'selection_count', 4);

%%
% A sample solution for this variable definition follows:
sol = ypea_generate_sample(var);
sol.c

%%
% The binary equivalent of multiple selection can be defined as:
var = ypea_var('d', 'binary_selection', 'size', [3 10], 'selection_count', 4);
sol = ypea_generate_sample(var);
sol.d

%%
% *Partition Variables* (|partition| and |binary_partition|)
%
% Partition or allocation variables are used to partition/assign/allocate
% some items to a list of predefined options.
% The number of partitions is specified by |partition_count|.
% The binary version, represents the solution as binary flags.
%
% _Some Examples_
%
%%
% This is a simple partition/allocation variable:
var = ypea_var('a', 'partition', 'size', 10, 'partition_count', 3);

%%
% which means partitioning of 10 items into 4 partitions.
% A sample solution may be:
sol = ypea_generate_sample(var);
sol.a

%%
% The same variable can be defined in binary form:
var = ypea_var('b', 'binary_partition', 'size', 10, 'partition_count', 3);

%%
% and a sample solution may be like this:
sol = ypea_generate_sample(var);
sol.b

%%
% Just like permutation and selection variables, it is possible to perform multiple
% partitions/allocations. For example, 2 partitioning operations, each of which is
% allocating 10 items to 3 options, can be defined as:
var = ypea_var('c', 'partition', 'size', [2 10], 'partition_count', 3);

%%
% A sample solution for this variable definition follows:
sol = ypea_generate_sample(var);
sol.c

%%
% The first allocation is given by:
sol.c{1}

%%
% The binary equivalent of multiple selection can be defined as:
var = ypea_var('d', 'binary_partition', 'size', [2 10], 'partition_count', 3);
sol = ypea_generate_sample(var);
sol.d

%%
sol.d{1}

%%
% *Fixed Sum Variable* (|sum|, |row_sum| and |col_sum| )
%
% Fixed sum variables represent are used to ensure that sum of some real valued
% numbers is exactly equal to a specified |target| value. This equality,
% can be defined for sum of all elements of a matrix or rows and columns of
% the matrix.
%
% _Some Examples_
%

%%
% For example, this defines a 3-by-4 matrix, which its sum of elements
% equals to 5:
var = ypea_var('x', 'sum', 'size', [3 4], 'target', 5);

%%
% Let's generate a sample of this:
sol = ypea_generate_sample(var);
sol.x

%%
% We can check the equality by:
sum(sol.x(:))

%%
% If the same variable set is defined to have fixed row sum, we will have:
var = ypea_var('x', 'row_sum', 'size', [3 4], 'target', 5);
sol = ypea_generate_sample(var);
sol.x

%%
% And the sum of rows of the sample is given by:
sum(sol.x, 2)

%%
% The fixed column sum version of this variable follows:
var = ypea_var('x', 'col_sum', 'size', [3 4], 'target', 5);
sol = ypea_generate_sample(var);
sol.x

%%
% And the sum of columns of the sample is given by:
sum(sol.x)
