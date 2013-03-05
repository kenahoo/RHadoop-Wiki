First a table to categorize keyval pairs. Keys and values fall in three categories: NULL, not-NULL but 0-length ("length" in the rmr sense, that is `nrow` for matrices and data frames, `length` otherwise) and the "normal case" (not-NULL, length greater than 0).

<table>
<tr><td>key/val</td><td>	NULL</td><td>	0-length such as integer(0)	</td><td>length > 0</td>
</tr><tr><td>NULL</td><td>	0-length keyval</td><td>	0-length keyval</td><td>	NULL keys</td>
</tr><tr><td>0-length such as integer(0)</td><td>	NO	</td><td>0-length keyval</td><td>NO</td>
</tr><tr><td>length > 0</td><td>	NO</td><td>	NO</td><td>	normal case</td>
</tr></table>

The idea is that NULL key means "keys omitted" or "not important". Typical use is map only jobs, or input to the map function. When combined with NULL or 0-length values, that creates an empty `keyval` pair, otherwise  a keyval pair with values but NULL keys. When the keys are not-NULL 0-length, values must be too and the two form an empty keyval pair. When the keys are non-zero length, the values should as well. So we have three categories of keyval pairs, 0-length (or empty), NULL keys and non-zero-length values, and non-zero-length everything. Can we mix and match them as argument to c.keyval and as return values from map and reduce. This is answered in the following table.


<table>
<tr><td>c.keyval</td><td>	0-length</td><td>	NULL keys</td><td>	normal case</td>
</tr><tr><td>0-length</td><td>	0-length</td><td>	NULL keys</td><td>	normal case</td>
</tr><tr><td>NULL keys</td><td></td><td>		NULL keys</td><td>	NO</td>
</tr><tr><td>normal case</td><td></td><td></td><td>			normal case</td>
</tr></table>


It is symmetric and can be summarized as follow:
1. 0-length is the neutral element and can be combined with every other type
2. each type can be combined with the same type (diagonal)
3. NULL keys with non-zero-length values can not be combined with the normal case.