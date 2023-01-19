class RouteRecognizer #Class define
  require 'rails' #Load rails libraly

  class InvalidRoutesError < StandardError; end 
  # Defind new error class inherite form build-in standart error 
  #raised by initialized method
  class NoMatchingRouteError < StandardError; end
  # Same as InvalidRoutesError but raised by recognize

  attr_accessor :router, :routes_as_string 
  #define Create getter and setter method for instance varriable
  def initialize(string='') 
  # define Constructor of class take string argument
    @routes_as_string = string
    #set string = instance variable routes_as_string 
    @routes = ActionDispatch::Routing::RouteSet.new
    #create ActionDispatch::Routing::RouteSet instance and assign to @route 
    #use to define and manage route app
    begin
      @routes.draw { eval string } unless string.blank?
      #Use draw method to evaluate string as code by initialize 
      #if it blank code block won't execute
    rescue Exception => e       # yes, really, because anything can happen inside an Eval
      # code block , use in catch execption pass to initialize method
      raise InvalidRoutesError, e.message
      #riase error massage with execption caught in previous line
    end
  end

  def recognize(method,uri) #define recognize method that take method and uri argument
    rack_request = RackRequest.new(method,uri)
    # Create new RackRequest obj. with give method and uri method
    request = ActionDispatch::Request.new(rack_request.env)
    # create ActionDispatch::Request with environment as RackRequest
    all_params = nil
    # all_params = nil and wait to store route parameter
    @routes.router.recognize(request) do |route,params|
      # Use router recognize method to match request to a route
      all_params = request.query_parameters.merge params
      #Store result of merge query parameter from request obj. with parameter return 
      #by router recognize method in all_params
      end
    raise NoMatchingRouteError unless all_params
    #raise NoMatchingRouteError if all_params not set (no matching route was found )
    all_params
    #hold merge query parameter from request obj. with parameter return by router recognize
  end

  
  class RackRequest
    attr_accessor :method, :uri, :query_string, :path, :env
    #Create getter and setter method for instance variable
    def initialize(method,uri)
    # define Constructor of class that take method and uri argument
      @method,@uri = method,uri
      #assign method and uri to instance variable
      set_query_string!
      set_env!
      #Call constructor to method to set value of @env and @query_string
    end
    
    private
    #set access permition of method to access only in class
    def set_env!
      #define Constructor of class 
      @env = {
        'REQUEST_URI' => uri,
        'PATH_INFO' => path,
        'REQUEST_METHOD' => method
      }
      #initialize hash and assign to @env instace variable
      @env.merge!({'QUERY_STRING' => query_string}) if query_string
      #If query_string not nil will add key-value to hash where key 'QUERY_STRING' and 
      #value is value of query_string
    end

    def set_query_string!
      #define Constructor of class       
      if @uri =~ /(.+)\?(.+)\Z/
        @path,@query_string = $1,$2
        #if uri pattern match in /(.+)\?(.+)\Z/
      else                        # no query string
        @path = @uri
        @query_string = nil
      end
    end

  end
end
