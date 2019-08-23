int time;
int stepduration = 20;
Snake snake;

boolean ai = true;

void setup()
{
  snake = new Snake(40, 20, 30, new PVector(40, 75));
  size(1280, 720);
  textFont(createFont("Liberation Sans", 36));
  textSize(36);
}

void draw()
{
  if(millis() - time >= stepduration)
  {
    if(ai)
    {
      Think();
    }
    snake.Update();
    this.time = millis();
    if(!snake.Alive)
    {
      if(ai)
      {
        path = null;
      }
      snake.Respawn();
    }
  }
  background(50);
  snake.Show();
  fill(255, 0, 0);
  text("Score: " + snake.Body.size(), 10, 35);
}

ArrayList<PVector> path;
int snakesize;

void Think()
{ 
  ArrayList<PVector> temppath = FindPath(snake, snake.Head(), snake.Food);
  if(temppath != null)
  {
    temppath.remove(0); // 0 index is the head of the snake
    
    // check if it is safe for the snake to go for the food

    if(SafeToGoForFood(snake.Copy(), temppath))
    {
      // path == null ... no path has been initialized
      // path.size() == 0 ... food has been found and new path is needed
      // temppath.size() < path.size() ... since the snake is constantly moving there may be a shorter path now that was blocked by bodypieces before
      if(path == null || path.size() == 0 || temppath.size() < path.size())
      {
        path = temppath;
      }
    }
    else if(!(path != null && path.size() > 0)) // if there wasn't a path before that was safe then calculate the max route to buy as much time as possible
    {
      path = FindLongestPath(snake, snake.Head(), snake.Food);
      path.remove(0);
    }
  }
  else
  {
    ArrayList<PVector> pathtotail = FindPath(snake, snake.Head(), snake.Tail());
    if(pathtotail != null)
    {
      path = pathtotail;
      path.remove(0);
    }
    else
    {
      int tailreachablein = TailReachableIn(snake);
      if(tailreachablein != -1)
      {
        pathtotail = FindLongestPath(snake, snake.Head(), snake.Body.get(snake.Body.size() - (tailreachablein + 1)));
        pathtotail.remove(0);
        path = pathtotail;
      }
    }
  }
  
  if(path != null)
  {
    if(path.size() > 0)
    {
      MoveSnake(snake, path);
    }
  }
}

ArrayList<PVector> FindPath(Snake snake, PVector start, PVector end)
{
  return snake.GetMap().FindPath(start, end);
}

ArrayList<PVector> FindLongestPath(Snake snake, PVector start, PVector end)
{
  return snake.GetMap().FindLongestPath(start, end);
}

boolean SafeToGoForFood(Snake snake, ArrayList<PVector> path)
{
  // Create future GameState when snake has grabbed food

  ArrayList<PVector> temppathcopy = DuplicatePath(path);
  while(temppathcopy.size() > 0)
  {
    MoveSnake(snake, temppathcopy);
    snake.Update();
  }
    
  return TailReachableIn(snake) != -1;
}

int TailReachableIn(Snake snake)
{ 
  // check if it can reach it's tail
  
  int tailreachableinsteps = 0;
  
  // go through the pieces of the snake backwards and see in how many steps the tail is reachable
  
  do
  {
    PVector tailpos = snake.Body.get(snake.Body.size() - (tailreachableinsteps + 1));
    
    ArrayList<PVector> pathtotail = FindLongestPath(snake, snake.Head(), tailpos);
    
    if(pathtotail != null && (pathtotail.size() - 2) >= tailreachableinsteps) // path to tail found and theres enough space, the -2 is because you have to subtract head and tail in this case
    {
      return tailreachableinsteps;
    }
    
    tailreachableinsteps++;
    
  } while(tailreachableinsteps < snake.Body.size());
  
  return -1;
}

ArrayList<PVector> DuplicatePath(ArrayList<PVector> path)
{
  if(path != null)
  {
    ArrayList<PVector> copy = new ArrayList<PVector>();
    
    for(PVector p : path)
    {
      copy.add(p.copy());
    }
    
    return copy;
  }
  else
  {
    return null;
  }
}

void MoveSnake(Snake snake, ArrayList<PVector> path)
{
  snake.Velocity = path.get(0).sub(snake.Head());
  path.remove(0);
}

void keyPressed()
{
  if(!ai)
  {
    switch(keyCode)
    {
      case UP:
        snake.SetVelocity(0, 1);
        break;
        
      case DOWN:
        snake.SetVelocity(0, -1);
        break;
        
      case LEFT:
        snake.SetVelocity(-1, 0);
        break;
        
      case RIGHT:
        snake.SetVelocity(1, 0);
        break;
    }
  }
}
