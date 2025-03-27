/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ingjimen <ingjimen@student.42madrid.c      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/03/25 09:19:01 by ingjimen          #+#    #+#             */
/*   Updated: 2025/03/25 09:19:03 by ingjimen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

int	execute(t_cmd *cmd, char **env)
{
	if (!cmd || !cmd->path || !cmd->args || !cmd->args[0])
		return (-1);
	if (access(cmd->path, X_OK) != 0)
		return (-1);
	execve(cmd->path, cmd->args, env);
	return (-1);
}

int	pipex(int ac, char **av, char **env)
{
	t_pipex	*pipex;
	int		pid1;
	int		pid2;
	int		pipend[2];

	pipex = parse_cmds(ac, av, env);
	if (pipe(pipend) == -1)
		(errors(5, NULL), free_pipex(pipex), exit(1));
	pid1 = fork();
	if (pid1 < 0)
		(free_pipex(pipex), exit(EXIT_FAILURE));
	if (pid1 == 0)
		child1(pipex, env, pipend);
	close(pipend[1]);
	pid2 = fork();
	if (pid2 < 0)
		(free_pipex(pipex), exit(EXIT_FAILURE));
	if (pid2 == 0)
		child2(pipex, env, pipend);
	close(pipend[0]);
	return (wait_childs(pid1, pid2, pipex));
}

int	main(int argc, char **argv, char **env)
{
	if (!*env || !env)
	{
		ft_putendl_fd("No enviroment found.", 2);
		exit(2);
	}
	if (argc != 5)
		(errors(1, NULL), exit(EXIT_FAILURE));
	return (pipex(argc, argv, env));
}
