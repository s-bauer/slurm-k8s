package cmd

import (
	"github.com/s-bauer/slurm-k8s/internal/installer"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

// initCmd represents the start command
var initCmd = &cobra.Command{
	Use:   "init",
	Short: "Start the kubernetes cluster",
	Run: func(cmd *cobra.Command, args []string) {
		if err := installer.Uninstall(); err != nil {
			log.Fatal(err)
		}
	},
}

func init() {
	rootCmd.AddCommand(initCmd)

	_ = viper.BindPFlags(startCmd.Flags())
}