BEGIN {
  RS = ORS = "\r\n"
  HttpService = "/inet/tcp/8081/0/0"
  Hello = "{\"this\": \"that is it\"}"
  Len = length(Hello) + length(ORS)
  print "HTTP/1.0 200 OK"          |& HttpService
  print "Pragma: no-cache"
  print "Content-Length: " Len ORS |& HttpService
  print Hello                      |& HttpService
  while ((HttpService |& getline) > 0)
     continue;
  close(HttpService)
}