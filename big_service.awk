function SetUpServer() {
  TopHeader = "<HTML><HEAD>"
  TopHeader = TopHeader \
     "<title>My name is GAWK, GNU AWK</title></HEAD>"
  TopDoc    = "<BODY><h2>\
    Do you prefer your date <A HREF=" MyPrefix \
    "/human>human</A> or \
    <A HREF=" MyPrefix "/POSIX>POSIXed</A>?</h2>" ORS ORS
  TopFooter = "</BODY></HTML>"
}

function CGI_setup(   method, uri, version, i) {
  delete GETARG;         delete MENU;        delete PARAM
  GETARG["Method"] = $1
  GETARG["URI"] = $2
  GETARG["Version"] = $3
  i = index($2, "?")
  # is there a "?" indicating a CGI request?
  if (i > 0) {
    split(substr($2, 1, i-1), MENU, "[/:]")
    split(substr($2, i+1), PARAM, "&")
    for (i in PARAM) {
      j = index(PARAM[i], "=")
      GETARG[substr(PARAM[i], 1, j-1)] = \
                                  substr(PARAM[i], j+1)
    }
  } else {    # there is no "?", no need for splitting PARAMs
    split($2, MENU, "[/:]")
  }
}

function HandleGET() {
  if (       MENU[3] == "human") {
    Footer = strftime() TopFooter
  } else if (MENU[3] == "POSIX") {
    Footer = systime()  TopFooter
  }
}

BEGIN {
  if (MyHost == "") {
     "uname -n" | getline MyHost
     close("uname -n")
  }
  if (MyPort ==  0) MyPort = 8080
  HttpService = "/inet/tcp/" MyPort "/0/0"
  MyPrefix    = "http://" MyHost ":" MyPort "/myservice"
  SetUpServer()
  while ("awk" != "complex") {
    # header lines are terminated this way
    RS = ORS = "\r\n"
    Status   = 200          # this means OK
    Reason   = "OK"
    Header   = TopHeader
    Document = TopDoc
    Footer   = TopFooter
    if        (GETARG["Method"] == "GET") {
        HandleGET()
    } else if (GETARG["Method"] == "HEAD") {
        # not yet implemented
    } else if (GETARG["Method"] != "") {
        print "bad method", GETARG["Method"]
    }
    Prompt = Header Document Footer
    print "HTTP/1.0", Status, Reason       |& HttpService
    print "Connection: Close"              |& HttpService
    print "Pragma: no-cache"               |& HttpService
    len = length(Prompt) + length(ORS)
    print "Content-length:", len           |& HttpService
    print ORS Prompt                       |& HttpService
    # ignore all the header lines
    while ((HttpService |& getline) > 0)
        ;
    # stop talking to this client
    close(HttpService)
    # wait for new client request
    HttpService |& getline
    # do some logging
    print systime(), strftime(), $0
    # read request parameters
    CGI_setup($1, $2, $3)
  }
}