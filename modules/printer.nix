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
    ];
  };
}
