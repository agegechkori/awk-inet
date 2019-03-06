# Client
BEGIN {
  "/inet/tcp/0/localhost/8888" |& getline
  print $0
  close("/inet/tcp/0/localhost/8888")
}