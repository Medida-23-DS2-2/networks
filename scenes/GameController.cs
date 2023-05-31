using Godot;
using System;

public class GameController : Node2D
{
  Grid grid = ResourceLoader.Load("res://grid/Grid.tres") as Grid;
  public override void _Ready()
  {

  }

  //  // Called every frame. 'delta' is the elapsed time since the previous frame.
  //  public override void _Process(float delta)
  //  {
  //      
  //  }
}
