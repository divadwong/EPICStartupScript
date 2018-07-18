# EPICStartupScript
Startup Scripts for EPIC PVS Servers. copies different test and prod files depending on build environment
The Servername's 8th Character determines what environment the server is in.
P = Production
Q = QA
D = Dev

The appropriate file (Test or Prod) is copied over upon startup.

Run the script from task scheduler using system credentials
