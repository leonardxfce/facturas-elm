port module Ports exposing (downloadFile, triggerPrint)


port triggerPrint : () -> Cmd msg


port downloadFile : { name : String, content : String } -> Cmd msg
