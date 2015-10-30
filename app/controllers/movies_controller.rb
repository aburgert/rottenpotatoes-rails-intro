class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = ['G','PG','PG-13','R']
    @selected_ratings = @all_ratings    #on first load
    if ((session.has_key? "ratings") && !(params.has_key? "ratings"))
      @selected_ratings = session["ratings"].keys
      #flash.keep
      ##redirect_to "url = url + utf8=✓& + ratings[#{rating}] for each rating
      params["ratings"]= session["ratings"]
      if(session.has_key?"sort" && (!params.has_key?"sort"))
        redirect_to movies_path(utf8: session["utf8"], ratings: session["ratings"], sort: session["sort"])
      elsif params.has_key?"sort"
        redirect_to movies_path(utf8: session["utf8"], ratings: session["ratings"], sort: params["sort"])
      else
        redirect_to movies_path(utf8: session["utf8"], ratings: session["ratings"])
      end
      return
    end
    if params.has_key? "ratings" #executes on every subsequent load (after implementing view-side code to check specified boxes in @selected_ratings)
      @selected_ratings = params["ratings"].keys
      session["utf8"] = params["utf8"]
      session["ratings"] = params["ratings"]
    end
    @movies = Movie.where(rating: @selected_ratings)
    if ((session.has_key? "sort") && !(params.has_key? "sort"))
      @movies = @movies.order(session["sort"])
      handle_hilite(session["sort"])
      #flash.keep
      params["sort"] = session["sort"]
      #redirect_to "url = url + sort=release_date"
      #redirect_to movies_path(sort: session["sort"])
      if(session.has_key?"ratings" && (!params.has_key?"ratings"))
        redirect_to movies_path(utf8: session["utf8"], ratings: session["ratings"], sort: session["sort"])
      elsif params.has_key?"ratings"
        redirect_to movies_path(utf8: params["utf8"], ratings: params["ratings"], sort: params["sort"])
      else
        redirect_to movies_path(sort: session["sort"])
      end
      return
    end
    if params.has_key? "sort"
      @movies = @movies.order(params["sort"])
      session["sort"] = params["sort"]
      handle_hilite(params["sort"])
    end
    #if sort requested from params[], @movies = Movie.find
    #Movie.order("title") or Movie.order("release_date") determined programatically from params[]
  end

  def new
    # default: render 'new' template
  end
  
  def handle_hilite (hilite_class)
    if hilite_class == "title"
           #flash[:notice] = "handling hilite"

      @titleClass = "hilite"
      @dateClass = ""
      @ratingClass= ""
    elsif hilite_class == "release_date"
      @titleClass = ""
      @dateClass = "hilite"
      @ratingClass= ""
    end
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
