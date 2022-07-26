"""
Contains templates and a helper macro [`@setupDocstringMarkup`](@ref) to easily
set up consistent docstring formats across modules.
"""
module Documentation

using DocStringExtensions

export @setupDocstringMarkup

@template (FUNCTIONS, MACROS, METHODS) = """
                                         $(TYPEDSIGNATURES)
                                         $(DOCSTRING)
                                         """

@template MODULES = """
                    $(DOCSTRING)

                    # Exports
                    $(EXPORTS)

                    # Imports
                    $(IMPORTS)
                    """

@template TYPES = """
                  $(TYPEDEF)
                  $(DOCSTRING)

                  # Fields
                  $(TYPEDFIELDS)
                  """

"""
Helper macro ensuring consistent docstring markup across modules through
templating.
"""
macro setupDocstringMarkup()
  # This needs to be done in separate `eval`s as otherwise the @template macro
  # will not yet be available for the latter definitions
  __module__.eval(:(using DocStringExtensions))
  __module__.eval(quote
    @template (FUNCTIONS, MACROS, METHODS) = Documentation
    @template MODULES = Documentation
    @template TYPES = Documentation
  end)
end

end
