/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   path_bonus.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:20:21 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:20:23 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex_bonus.h"

char	*find_cmd_path(char *cmd_name, char **env)
{
	if (ft_strchr(cmd_name, '/'))
		return (check_direct_path(cmd_name));
	return (search_in_path(cmd_name, env));
}

t_cmd	*create_cmd(char *arg, char **env, t_pipex *pipex)
{
	t_cmd	*cmd;

	cmd = malloc(sizeof(t_cmd));
	if (!cmd)
	{
		errors(3, "malloc");
		free_pipex(pipex);
		exit(EXIT_FAILURE);
	}
	cmd->origin_cmd = ft_strdup(arg);
	cmd->args = ft_split(cmd->origin_cmd, ' ');
	if (!cmd->args || !cmd->args[0])
	{
		errors(4, cmd->origin_cmd);
		free_pipex(pipex);
		exit(127);
	}
	cmd->path = find_cmd_path(cmd->args[0], env);
	if (!cmd->path)
		errors(4, cmd->origin_cmd);
	return (cmd);
}

void	parse_cmds(t_pipex *pipex, char **av, char **env)
{
	int	i;
	int	offset;

	if (pipex->here_doc == 1)
		offset = 3;
	else
		offset = 2;
	pipex->cmds = malloc(sizeof(t_cmd *) * (pipex->number_cmds + 1));
	if (!pipex->cmds)
	{
		errors(3, "malloc");
		exit(EXIT_FAILURE);
	}
	i = 0;
	while (i < pipex->number_cmds)
	{
		pipex->cmds[i] = create_cmd(av[i + offset], env, pipex);
		i++;
	}
	pipex->cmds[i] = NULL;
}
