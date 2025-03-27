/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   path.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:18:48 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:18:52 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

char	*search_in_path(char *cmd_name, char **env)
{
	char	**paths;
	char	*joined;
	char	*path_var;
	int		i;

	path_var = get_env_path(env);
	if (!path_var)
		return (NULL);
	paths = ft_split(path_var, ':');
	if (!paths)
		return (NULL);
	i = 0;
	while (paths[i])
	{
		joined = join_path(paths[i], cmd_name);
		if (access(joined, X_OK) == 0)
		{
			ft_free_split(paths);
			return (joined);
		}
		free(joined);
		i++;
	}
	ft_free_split(paths);
	return (NULL);
}

char	*find_cmd_path(char *cmd_name, char **env)
{
	if (!cmd_name || cmd_name[0] == '\0')
		return (NULL);
	if (ft_strchr(cmd_name, '/'))
		return (check_direct_path(cmd_name));
	return (search_in_path(cmd_name, env));
}
