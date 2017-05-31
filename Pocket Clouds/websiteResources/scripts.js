
var isLoading = false;

function toggleLoader()
{
    var loader = document.getElementById("loader")
    if (isLoading)
    {
        loader.style.display = 'none';
        isLoading = false;
    }
    else
    {
        loader.style.display = 'initial';
        isLoading = true;
    }
}




