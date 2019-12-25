require '../../spec'
# gnokii --showsmsfolderstatus
# gnokii --getsms SM 1
# gnokii --deletesms SM 1
# 

describe Wio::Gnokii do
  
  before do
    @gnokii = Wio::Gnokii
  end
  
  it 'should convert numbers that start with zero to normal' do
    @gnokii.normalize('09292285564').should.equal '639292285564'
  end
  
  it 'should convert normal numbers to format that starts with zero' do
    @gnokii.denormalize('+639292285564').should.equal '09292285564'
    @gnokii.denormalize('639292285564').should.equal '09292285564'
  end
  
  it 'should flip number format between normal and zero' do
    @gnokii.flip_number_format('+639292285564').should.equal '09292285564'
    @gnokii.flip_number_format('639292285564').should.equal '09292285564'
    @gnokii.flip_number_format('09292285564').should.equal '639292285564'
  end
  
  it 'should correctly parse number when doing multiple operations' do
    number = '+639292285564'
    (number = @gnokii.denormalize(number)).should.equal '09292285564'
    number.should.equal '09292285564'
    (number = @gnokii.flip_number_format(number)).should.equal '639292285564'
    number.should.equal '639292285564'
  end
  
  it 'should parse showsmsfolderstatus' do
    @gnokii.parse_smsfolderstatus(
"No. Name                               Id #Msg
==============================================
  0 SIM card                           SM    6
"
    ).should.equal 6
  end
  
  it 'should parse getsms message' do
    @gnokii.parse_getsms(
      "2. Inbox Message (Unread)
Date/time: 22/02/2009 18:36:10 +0800
Sender: +639292285564 Msg Center: +639180000129
Text:
Karasa
Manaka
dododo
"
    ).should.equal({:id => 2, :sender => '+639292285564', :text => "Karasa\nManaka\ndododo"})
  end
  
  it 'should parse getsms message' do
    @gnokii.parse_deletesms(
"GNOKII Version 0.6.27
LOG: debug mask is 0x1
Config read from file /home/charlotte/.gnokiirc.
phone instance config:
model = 6110
port = /dev/ttyS0
connection = m2bus
initlength = default
serial_baudrate = 19200
serial_write_usleep = -1
handshake = software
require_dcd = 0
smsc_timeout = 10
rfcomm_channel = 0
sm_retry = 0
Serial device: opening device /dev/ttyS0
Serial device: setting speed to 9600
Serial device: setting RTS to high and DTR to low
Message sent: 0x40 / 0x0004
00 01 64 01                                     |   d             
Serial device: setting RTS to low and DTR to low
Serial device: setting RTS to high and DTR to low
[Received Ack, seq:  2]
[Sending Ack, seq: 25]
Message received: 0x40 / 0x000c
01 01 64 03 01 4f 0d 01 01 01 1b 58             |   d  O     X    
Received message type 40
Message: Extended commands enabled.
Message sent: 0x40 / 0x0003
00 01 66                                        |   f             
Serial device: setting RTS to low and DTR to low
Serial device: setting RTS to high and DTR to low
[Received Ack, seq:  3]
[Sending Ack, seq: 26]
Message received: 0x40 / 0x0014
01 01 66 01 33 35 30 38 33 35 36 30 32 34 37 33 |   f 350835602473
32 34 36 00                                     | 246             
Received message type 40
IMEI: 350835602473246
Message sent: 0x40 / 0x0004
00 01 64 01                                     |   d             
Serial device: setting RTS to low and DTR to low
Serial device: setting RTS to high and DTR to low
[Received Ack, seq:  4]
[Sending Ack, seq: 27]
Message received: 0x40 / 0x000c
01 01 64 03 01 4f 0d 01 01 01 1b 58             |   d  O     X    
Received message type 40
Message: Extended commands enabled.
Message sent: 0x40 / 0x0004
00 01 c8 01                                     |                 
Serial device: setting RTS to low and DTR to low
Serial device: setting RTS to high and DTR to low
[Received Ack, seq:  5]
[Sending Ack, seq: 28]
Message received: 0x40 / 0x0025
01 01 c8 01 00 56 20 30 35 2e 34 35 0a 30 39 2d |      V 05.45 09-
30 34 2d 30 32 0a 4e 48 4d 2d 35 0a 28 63 29 20 | 04-02 NHM-5 (c) 
4e 4d 50 2e 00                                  | NMP.            
Received message type 40
Received SW 05.45
Received model NHM-5
Message sent: 0x40 / 0x0004
00 01 64 01                                     |   d             
Serial device: setting RTS to low and DTR to low
Serial device: setting RTS to high and DTR to low
[Received Ack, seq:  6]
[Sending Ack, seq: 29]
Message received: 0x40 / 0x000c
01 01 64 03 01 4f 0d 01 01 01 1b 58             |   d  O     X    
Received message type 40
Message: Extended commands enabled.
Message sent: 0x40 / 0x0004
00 01 c8 05                                     |                 
Serial device: setting RTS to low and DTR to low
Serial device: setting RTS to high and DTR to low
[Received Ack, seq:  7]
[Sending Ack, seq: 2a]
Message received: 0x40 / 0x000a
01 01 c8 05 00 31 30 30 32 00                   |      1002       
Received message type 40
Received SW 05.45, HW 1002
Found model \"NHM-5\"
Message sent: 0x14 / 0x0006
00 01 00 0a 02 01                               |                 
Serial device: setting RTS to low and DTR to low
Serial device: setting RTS to high and DTR to low
[Received Ack, seq:  8]
[Sending Ack, seq: 2b]
Message received: 0x14 / 0x0004
01 08 00 0b                                     |                 
Received message type 14
Message: SMS deleted successfully.
Deleted SMS SM 1
Serial device: closing device"
    ).should.equal({:success => true, :id => 1})
  end
  
end
