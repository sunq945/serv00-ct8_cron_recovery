<!DOCTYPE html>
<html>
    <head>
        <title>PHP Test</title>
    </head>
    <body>
        <?php echo '<p>Hello World</p>';
            $config = array();
            
            //读取配置文件
            $jsonData = file_get_contents('data.json');
            
            //将JSON数据转换为对象
            $data = json_decode($jsonData);
            //var_dump($data );
            $cmd = $data->cmd;
            $localname = $data->WEB_USERNAME;
            $localpsw = $data->WEB_PASSWORD;

            $oname = $_GET["name"];
            $opsw = $_GET["psw"];
            if(  $oname ||  $opsw ) {
                // echo "name :". $oname. "<br />";
                // echo "password : ". $opsw. "<br />";
                // echo "cmd :$cmd";
                if( $oname == $localname && $opsw==$localpsw)
                {
                    $output = shell_exec("$cmd");
                    echo "<p>output =【 $output 】</p>";
                }                 
            }

        ?>
    </body>
</html>
