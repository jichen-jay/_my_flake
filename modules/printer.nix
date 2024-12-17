{ pkgs, ... }:

{

  environment.systemPackages = [
    pkgs.epson-escpr2
  ];

  services.printing.drivers = [
    pkgs.gutenprint # For many different printers
    pkgs.brlaser # For Brother printers
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
  };

  hardware.printers = {
    ensurePrinters = [{
      name = "PrinterName";
      location = "Home";
      deviceUri = "ipp://printer-ip-address:631/printers/PrinterName";
      model = "drv:///sample.drv/generic.ppd";
      ppdOptions = {
        PageSize = "Letter";
      };
    }];
  };
}
