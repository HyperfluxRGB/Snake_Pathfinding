class MapNode
{
  // Time until this node + the guessed time
  float f()
  {
    return g + h;    
  }
  
  float g; // time it takes to get to this node
  float h; // the guessed time until the end / the heuristic
  
  boolean Blocked; // whether or not you can pass this node
  
  MapNode Previous; // The node previous on the current path
  // (needed to reconstruct the path)
  
  PVector Position;
  
  public MapNode(float g, float h, boolean blocked, PVector position)
  {
    this.g = g;
    this.h = h;
    this.Blocked = blocked;
    this.Position = position;
  }
}
