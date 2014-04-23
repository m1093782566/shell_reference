#/bin/bash
repeat()
{
  while true
  do
    $@ && return
  done
}

#usage:
#If you try to download a resource which is temprorily unreachable, you can try command:
#repeat wget -c http://url
