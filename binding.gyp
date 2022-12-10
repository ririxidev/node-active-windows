{
  "targets": [
    {
      "target_name": "addon",
      "cflags!": [ "-fno-exceptions" ],
      "cflags_cc!": [ "-fno-exceptions" ],
      "conditions": [
        ["OS=='mac'", {
          "sources": [ '<!@(ls -1 addon/macos/*.mm)', "<!@(ls -1 addon/macos/functions/*.mm)" ],
          "libraries": [ "-framework AppKit", "-framework ApplicationServices", "-framework CoreGraphics"],
        }]
      ],
      "include_dirs": [
        "<!@(node -p \"require('path').relative(process.cwd(),require('node-addon-api').include.replace(/\\\"/g,''))\")"
      ],
      'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ]
    }
  ]
}