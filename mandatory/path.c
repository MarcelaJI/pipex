#include "pipex.h"

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


char	*get_env_path(char **env)
{
	int	i;

	i = 0;
	while (env[i])
	{
		if (ft_strncmp(env[i], "PATH=", 5) == 0)
		{
			return (env[i] + 5);
		}
		i++;
	}
	return (NULL);
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


char	*find_cmd_path(char *cmd_name, char **env)
{
	if (ft_strchr(cmd_name, '/'))
		return (check_direct_path(cmd_name));
	return (search_in_path(cmd_name, env));
}



void	parse_cmds(t_pipex *pipex, char **av, char **env)
{
	int		i;
	t_cmd	*cmd;

	i = 0;
	pipex->cmds = malloc(sizeof(t_cmd *) * (pipex->number_cmds + 1));
	if (!pipex->cmds)
		(errors(3, "malloc"), exit(EXIT_FAILURE));
	while (i < pipex->number_cmds)
	{
		cmd = malloc(sizeof(t_cmd));
		if (!cmd)
			(errors(3, "malloc"), free_pipex(pipex), exit(EXIT_FAILURE));
		cmd->origin_cmd = ft_strdup(av[i + 2]);
		cmd->args = ft_split(cmd->origin_cmd, ' ');
		cmd->path = find_cmd_path(cmd->args[0], env);
		pipex->cmds[i++] = cmd;
	}
	pipex->cmds[i] = NULL;
}

