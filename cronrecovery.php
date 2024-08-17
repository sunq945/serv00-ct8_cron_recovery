<!DOCTYPE html>
<html>
    <head>
        <title>crontab_recovery</title>
    </head>
    <body>
        <?php echo '<p>Hello World</p>';

        function base64UrlDecode(string $input)
        {
            $remainder = strlen($input) % 4;
            if ($remainder) {
            $addlen = 4 - $remainder;
            $input .= str_repeat('=', $addlen);
            }
            return base64_decode(strtr($input, '-_', '+/'));
        }


            $payload = array();
            
            //读取配置文件
            $jsonData = file_get_contents('data.json');
            
            //将JSON数据转换为对象
            $data = json_decode($jsonData);
            //var_dump($data );
            $cmd = $data->cmd;
            $localname = $data->WEB_USERNAME;
            $localpsw = $data->WEB_PASSWORD;

            $base64payload = $_GET["token"];           
            
            $payload = json_decode(base64UrlDecode($base64payload), JSON_OBJECT_AS_ARRAY);
          
            $oname = $payload["name"];
            $opsw = $payload["psw"];
            if(  $oname ||  $opsw ) {
                // echo "name :". $oname. "<br />";
                // echo "password : ". $opsw. "<br />";
                // echo "cmd :$cmd";
                if( $oname == $localname && $opsw==$localpsw)
                {
                    $output = shell_exec("$cmd");
                    echo "<p>output =[$output]</p>";
                }                 
            }

        ?>
    </body>
</html>
