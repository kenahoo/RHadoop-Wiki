<table>
<tr><td>key/val</td><td>	NULL</td><td>	0-length such as integer(0)	</td><td>length > 0</td>
</tr><tr><td>NULL</td><td>	0-length keyval</td><td>	0-length keyval</td><td>	NULL keys</td>
</tr><tr><td>0-length such as integer(0)</td><td>	NO	</td><td>0-length keyval</td><td>NO</td>
</tr><tr><td>length > 0</td><td>	NO</td><td>	NO</td><td>	normal case</td>
</tr></table>

<table>
<tr><td>c.keyval</td><td>	0-length</td><td>	NULL keys</td><td>	normal case</td>
</tr><tr><td>0-length</td><td>	0-length</td><td>	NULL keys</td><td>	normal case</td>
</tr><tr><td>NULL keys</td><td></td><td>		NULL keys</td><td>	NO</td>
</tr><tr><td>normal case</td><td></td><td></td><td>			normal case</td>
</tr></table>