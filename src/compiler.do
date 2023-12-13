# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog DinoGame.v DinoVideo.v HexDecoder.v PongController.v PongGame.v PongVideo.v PS2.v Randomizer.v sdram_controller.v Utility.v VGA.v
