//spark-shell --master=yarn --conf "spark.jars.packages=com.amazonaws:aws-java-sdk:1.11.984,org.scalaj:scalaj-http_2.11:0.3.15"
import scalaj.http.{Http, HttpOptions}
import org.json4s.jackson.JsonMethods._
import com.amazonaws.auth.BasicSessionCredentials
import com.amazonaws.auth.AWSStaticCredentialsProvider
import com.amazonaws.services.s3.AmazonS3Client
import com.amazonaws.services.s3.AmazonS3URI

object getAWSCredentials extends App {
    
    val id_broker_host = "id-broker-host.cloudera.site"

    //Retreive credentials from ID Broker
    val id_broker_request = Http("https://"+id_broker_host+":8444/gateway/dt/knoxtoken/api/v1/token")
    val id_broker_token = (parse(id_broker_request.asString) \ "access_token").values.toString
    val auth_header = Map("Authorization" -> s"Bearer $id_broker_token", "cache-control" ->  "no-cache")
    val id_broker_credentials_request = Http("https://"+id_broker_host+":8444/gateway/aws-cab/cab/api/v1/credentials").headers(auth_header)
    val id_broker_credentials = parse(id_broker_credentials_request.asString) \\ "Credentials"
    val aws_access_key = (id_broker_credentials \ "AccessKeyId").values.toString
    val aws_secret_key = (id_broker_credentials \ "SecretAccessKey").values.toString
    val aws_session_token = (id_broker_credentials \ "SessionToken").values.toString
    val session_expiry_unixms = (id_broker_credentials \ "Expiration").values.toString.toLong
    //val now = System.currentTimeMillis
    //val is_credential_valid = (session_expiry_unixms - 10000) > now

    // Use the retreived credentials with AWS Java SDK  
    val aws_session_credentials = new BasicSessionCredentials(aws_access_key, aws_secret_key, aws_session_token)
    val aws_credentials = new AWSStaticCredentialsProvider(aws_session_credentials)
    val s3_client = AmazonS3Client.builder.withCredentials(aws_credentials).build
    val s3_file_uri = new AmazonS3URI("s3://bucket-name/data/test.csv")
    val content = s3_client.getObjectAsString(s3_file_uri.getBucket, s3_file_uri.getKey).trim
    print(content)

}