<?php
$shell = shell_exec("./cannibal.sh ".$_REQUEST['userid']);
$a = json_decode(json_encode((array) simplexml_load_string($shell)),1);
?>
<html>
<head>
<title>output</title>
</head>
<body>
<table border="1">
<th>id</th>
<th>date</th>
<th>title</th>
<th>url</th>
<th>tags</th>
<?php
foreach($a['bookmarks']['bookmark'] as $bookmark) {
?>
<tr>
<td><?php echo $bookmark['id']; ?></td>
<td><?php echo date('r',$bookmark['date']); ?></td>
<td><?php echo $bookmark['title']; ?></td>
<td><a href="<?php echo $bookmark['url']; ?>"><?php echo $bookmark['url']; ?></a></td>
<?php
$tags = "";
foreach($bookmark['tags']['tag'] as $tag) {
$tags .= $tag['title'] .", ";
}
?>
<td><?php echo $tags; ?></td>
</tr>
<?php
}
?>
</table>
</html>

