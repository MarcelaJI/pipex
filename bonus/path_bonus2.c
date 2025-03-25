/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   path_bonus2.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:29:12 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:29:16 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex_bonus.h"

char	*get_env_path(char **env)
{
	int	i;

	i = 0;
	while (env[i])
	{
		if (ft_strncmp(env[i], "PATH=", 5) == 0)
			return (env[i] + 5);
		i++;
	}
	return (NULL);
}

char	*join_path(char *folder, char *cmd)
{
	char	*temp;
	char	*full_path;

	temp = ft_strjoin(folder, "/");
	if (!temp)
		return (NULL);
	full_path = ft_strjoin(temp, cmd);
	free(temp);
	return (full_path);
}

char	*check_direct_path(char *cmd_name)
{
	if (access(cmd_name, X_OK) == 0)
		return (ft_strdup(cmd_name));
	return (NULL);
}

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
