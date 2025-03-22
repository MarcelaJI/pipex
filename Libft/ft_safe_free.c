
#include "libft.h"

void    *ft_safe_free(void **ptr)
{
    if (ptr != NULL && *ptr != NULL)
    {
        free(*ptr);
        *ptr = NULL;
    }
    return (NULL);
}