{ pkgs, ... }:

{

  environment.systemPackages = [
    pkgs.epson-escpr2
  ];

  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.brlaser
    pkgs.hplip
  ];

  services.printing = {
    enable = true;
    browsing = true;
    browsedConf = ''
      BrowseDNSSDSubTypes _cups,_print
      BrowseLocalProtocols all
      BrowseRemoteProtocols all
      CreateIPPPrinterQueues All
      BrowseProtocols all
    '';
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "ET-2850";
        location = "Home";
        deviceUri = "ipp://printer-ip-address:631/printers/PrinterName";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
      {
        name = "VirtualPostScript";
        deviceUri = "file:///tmp/print.ps";
        model = "drv:///sample.drv/generic.ppd";
        description = "Virtual PostScript Printer";
        ppdOptions = {
          PageSize = "A4";
          ColorModel = "RGB";
          Resolution = "2400x1200dpi";
          MediaType = "Plain";
        };
      }
    ];
  };
}
