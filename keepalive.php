<!DOCTYPE html>
<html>
    <head>
        <title>PHP Test</title>
    </head>
    <body>
        <?php echo '<p>Hello World</p>';
            //$output = shell_exec('nohup /bin/bash /usr/home/sqshining/test.sh > /dev/null 2>&1 &');
            //echo "<p>output = $output</p>";
            $config = array();
            
            //打印读取到的文件内容
            //var_dump(file_get_contents("keepalive.conf"));
            $jsonData = file_get_contents('data.json');
            
            //将JSON数据转换为对象
            $data = json_decode($jsonData); 
            //var_dump($config);

            //$cmd = "/bin/bash /usr/home/sqshining/test.sh"
            $cmd = $data['name'];

            //$last_line = system($cmd,$return_val);
            //echo(“last line:”.$last_line);
            //echo(“return:”.$return_val);
        ?>
    </body>
</html>
