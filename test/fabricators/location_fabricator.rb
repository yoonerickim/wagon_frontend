Fabricator(:address) do
  lat 2.0
  lng 2.0
end
Fabricator(:vendor) do
  name "Dave's Pizza"
end
Fabricator(:location) do
  phone "6046046044"
  dine_in true
end
Fabricator(:menu) do
  name "Dinner"
end
