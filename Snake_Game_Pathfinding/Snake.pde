class Snake
{
  // drawing stuff
  
  PVector Offset;
  
  int Gridsize;
  
  // snake stuff
  
  PVector Head()
  {
    return this.Body.get(0);
  }
  
  PVector Tail()
  {
    return this.Body.get(this.Body.size() - 1);
  }
  
  int Length()
  {
    return this.Body.size();
  }
  
  ArrayList<PVector> Body;
  
  PVector Velocity;
  
  PVector Food;
  
  int Width;
  
  int Height;
  
  boolean Alive;
  
  public Snake Copy()
  {
    Snake clone = new Snake(Width, Height, Gridsize, Offset.copy());
    clone.Alive = Alive;
    clone.Food = Food.copy();
    clone.Velocity = Velocity.copy();
    ArrayList<PVector> bodycopy = new ArrayList<PVector>();
    for(PVector bodypiece : Body)
    {
      bodycopy.add(bodypiece.copy());
    }
    clone.Body = bodycopy;
    
    return clone;
  }
  
  public void Respawn()
  {
    this.Alive = true;
    this.Body = new ArrayList<PVector>();
    this.Body.add(new PVector(floor(Width / 2), floor(Height / 2)));
    this.Body.add(new PVector(floor(Width / 2), floor(Height / 2) - 1));
    this.Body.add(new PVector(floor(Width / 2) + 1, floor(Height / 2) - 1));
    this.Body.add(new PVector(floor(Width / 2) + 1, floor(Height / 2)));
    //this.Body.add(new PVector(floor(Width / 2) - 1, floor(Height / 2)));
    //this.Body.add(new PVector(floor(Width / 2) - 2, floor(Height / 2)));
    this.SetVelocity(1, 0);
  }
  
  void PickFoodLocation()
  {
    PVector newlocation;
    do
    {
      newlocation = new PVector(floor(random(Width - 1)) + 1, floor(random(Height - 1)) + 1);
    } while(TouchesTail((int)newlocation.x, (int)newlocation.y));
    
    this.Food = newlocation;
  }
  
  boolean TouchesTail(int x, int y)
  {
    for(PVector tailpiece : this.Body)
    {
      if(x == tailpiece.x && y == tailpiece.y)
      {
        return true;
      }
    }
    
    return false;
  }
  
  public Snake(int _width, int _height, int gridsize, PVector offset)
  {
    if(_width < 10 || _height < 10)
    {
      throw new IllegalArgumentException("Width or Height is less than 10.");
    }
    
    if(gridsize < 10)
    {
      throw new IllegalArgumentException("Gridsize is less than 10.");
    }
    
    if(offset == null)
    {
      this.Offset = new PVector();
    }
    else
    {
      this.Offset = offset;
    }
    
    this.Gridsize = gridsize;
    this.Width = _width;
    this.Height = _height;    
    this.Respawn();
    this.PickFoodLocation();
  }
  
  void SetVelocity(int x, int y)
  {
    this.Velocity = new PVector(x, y);
  }
  
  boolean OutsideBorders(int x, int y)
  {
    if(x < 0 || y < 0 || x >= this.Width || y >= this.Height)
    {
      return true;
    }
    
    return false;
  }
  
  boolean WillDie()
  {
    PVector newpos = new PVector(Head().x + Velocity.x, Head().y + Velocity.y);
    if(OutsideBorders((int) newpos.x, (int) newpos.y))
    {
      return true;
    }
    
    if(TouchesTail((int)newpos.x, (int)newpos.y))
    {
      // check if the snake touched the tail. if it did then it didn't die.
      
      return !Tail().equals(new PVector(newpos.x, newpos.y));
    }
    
    return false;
  }
  
  void Move()
  { 
    if(this.Head().x + this.Velocity.x == this.Food.x 
      && this.Head().y + this.Velocity.y == this.Food.y)
    {
      Eat();
    }
    else
    {
      // Shift the positions from the body back by 1
      for(int i = this.Length() - 1; i > 0; i--)
      {
        this.Body.set(i, this.Body.get(i - 1));
      }

      this.Body.set(0, new PVector(this.Head().x + this.Velocity.x, this.Head().y + this.Velocity.y));
    }
  }
  
  void Eat()
  {
    this.Body.add(0, this.Food);
    this.PickFoodLocation();
  }
  
  void Update()
  {
    if(this.Alive)
    {
      if(!WillDie())
      {
        Move();
      }
      else
      {
        this.Alive = false;
      }
    }
  }
  
  Map GetMap()
  {
    Map snakeplayingfieldmap = new Map(this.Width, this.Height);
    
    for(PVector bodypiece : this.Body)
    {
      snakeplayingfieldmap.GetNode((int) bodypiece.x, (int) bodypiece.y).Blocked = true;
    }
    
    return snakeplayingfieldmap;
  }
  
  void Show()
  {
    imageMode(CENTER);
    stroke(0);
    strokeWeight(1f);
    // show body
    //fill(255, 215, 0);
    fill(255);
    for(PVector tailpos : this.Body)
    {
      // if(tailpos == Head() || tailpos == Tail()) fill(0);
      // else fill(255);
      rect(this.Offset.x + tailpos.x * this.Gridsize, this.Offset.y + this.Height * this.Gridsize - (tailpos.y + 1) * this.Gridsize, this.Gridsize * 0.98f, this.Gridsize * 0.98f);
    }
    // show food
    //fill(255, 233, 0); // 19, 233, 0 or 255, 233, 0
    fill(255, 0, 0);
    rect(this.Offset.x + this.Food.x * this.Gridsize, this.Offset.y + this.Height * this.Gridsize - (this.Food.y + 1) * this.Gridsize, this.Gridsize * 0.98f, this.Gridsize * 0.98f);
    
    float gridsizehalf = this.Gridsize / 2;
    
    // show border
    stroke(255);
    strokeWeight(gridsizehalf);
    // top line
    line(this.Offset.x - gridsizehalf, this.Offset.y - gridsizehalf, this.Offset.x + gridsizehalf + this.Width * this.Gridsize, this.Offset.y - gridsizehalf);
    // right line
    line(this.Offset.x + gridsizehalf + this.Width * this.Gridsize, this.Offset.y - gridsizehalf, this.Offset.x + gridsizehalf + this.Width * this.Gridsize, this.Offset.y + gridsizehalf + this.Height * this.Gridsize);
    // left line
    line(this.Offset.x - gridsizehalf, this.Offset.y - gridsizehalf, this.Offset.x - gridsizehalf, this.Offset.y + gridsizehalf + this.Height * this.Gridsize);
    // bottom line
    line(this.Offset.x - gridsizehalf, this.Offset.y + gridsizehalf + this.Height * this.Gridsize, this.Offset.x + gridsizehalf + this.Width * this.Gridsize, this.Offset.y + gridsizehalf + this.Height * this.Gridsize);
  }
}
