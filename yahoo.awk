BEGIN {
  RS = ORS = "\r\n"
  HttpService = "/inet/tcp/0/0/80"
  print "GET http://www.yahoo.com"     |& HttpService
  while ((HttpService |& getline) > 0)
     print $0
  close(HttpService)
}